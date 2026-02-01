--------------------------------
-- SQL TASK 6 ------------------
--------------------------------

-- 1. Display the names of athletes who won a gold medal in the 
--    2008 Olympics and whose height is greater than the average height 
--    of all athletes in the 2008 Olympics.
SELECT * FROM olympics
WHERE Year = 2008 AND Medal = 'Gold' AND
Height > (SELECT AVG(Height) FROM olympics WHERE Year = 2008);


-- 2. Display the names of athletes who won a medal in the sport of basketball
--    in the 2016 Olympics and whose weight is less than the average weight
--    of all athletes who won a medal in the 2016 Olympics.
SELECT name FROM olympics
WHERE Year = 2016 AND
Sport = 'Basketball' AND 
Medal IS NOT NULL AND
height < (SELECT AVG(Height) FROM olympics WHERE Year = 2016
		  AND Medal IS NOT NULL);


-- 3. Display the names of all athletes who have won a medal in the sport
--    of swimming in both the 2008 and 2016 Olympics.
SELECT * FROM olympics
WHERE Sport = 'Swimming' AND
Year IN (2008,2016) AND
Medal IS NOT NULL;    -- count if win in any of them , but we want both 

-- Updated Solution:
# Using Group By:
SELECT Name FROM olympics
WHERE Sport = 'Swimming'
  AND Year IN (2008, 2016)
  AND Medal IS NOT NULL
GROUP BY Name
HAVING COUNT(DISTINCT Year) = 2
ORDER BY Name;

# Using Sub Query:

SELECT DISTINCT Name
FROM olympics
WHERE Sport = 'Swimming'
  AND Medal IS NOT NULL
  AND Name IN (
    SELECT Name
    FROM olympics
    WHERE Sport = 'Swimming' AND Year = 2008 AND Medal IS NOT NULL
  )
  AND Name IN (
    SELECT Name
    FROM olympics
    WHERE Sport = 'Swimming' AND Year = 2016 AND Medal IS NOT NULL
  ) ORDER BY Name;
# Using Inner Join:

SELECT Distinct(t1.Name) FROM (SELECT Name FROM olympics
WHERE Year = 2016 AND Sport = 'Swimming' AND Medal IN ('Gold','Silver','Bronze')) t1
INNER JOIN
(SELECT Name FROM olympics
WHERE Year = 2008 AND Sport = 'Swimming' AND Medal IN ('Gold','Silver','Bronze')) t2
ON t1.Name = t2.Name
Order By Name;





-- 4. Display the names of all countries that have won more than 50 medals
--    in a single year.
SELECT country,Year,COUNT(*) FROM olympics
WHERE Medal IS NOT NULL AND country IS NOT NULL
GROUP BY country,Year
HAVING COUNT(*) > 50
ORDER BY Year,country;



-- 5. Display the names of all athletes who have won medals in 
--    more than one sport in the same year.
SELECT DISTINCT name FROM olympics
WHERE ID in (SELECT DISTINCT ID FROM olympics
			WHERE Medal IS NOT NULL
			GROUP BY ID,Year,Sport
			HAVING COUNT(Medal) > 1
			ORDER BY COUNT(Medal) DESC);
            

-- 6. What is the average weight difference between male and female athletes 
--    in the Olympics who have won a medal in the same event?

WITH result AS (SELECT * FROM olympics
				WHERE Medal IS NOT NULL)
SELECT AVG(A.Weight - B.Weight) FROM result A
JOIN result B
ON A.Event = B.Event
AND A.Gender != B.Gender;


-- 7. How many patients have claimed more than the average claim amount
--    for patients who are smokers and have at least one child, 
--    and belong to the southeast region?

SELECT COUNT(claim) FROM insurance
WHERE claim > (SELECT AVG(Claim) FROM insurance
				WHERE smoker = 'Yes' AND
				region = 'southwest' AND
				children >= 1); 



-- 8. How many patients have claimed more than the average claim amount
--    for patients who are not smokers and have a BMI greater than the 
--    average BMI for patients who have at least one child?

SELECT COUNT(claim) FROM insurance
WHERE claim > (SELECT AVG(claim) FROM insurance
				WHERE smoker = 'No' AND
				bmi > (SELECT AVG(bmi) FROM insurance
						WHERE children >= 1));


-- 9. How many patients have claimed more than the average claim amount
--    for patients who have a BMI greater than the average BMI for patients
--    who are diabetic, have at least one child, and are from the 
--    southwest region?
SELECT COUNT(claim) FROM insurance
WHERE claim > (SELECT AVG(claim) FROM insurance WHERE
			   bmi > (SELECT AVG(bmi) FROM insurance
					  WHERE children >= 1 AND
                      diabetic = 'Yes' AND
                      region = 'southwest'));



-- 10. What is the difference in the average claim amount between patients
--     who are smokers and patients who are non-smokers, and have the same BMI
--     and number of children?
SELECT AVG(A.claim - B.claim) FROM insurance A
JOIN insurance B
ON A.bmi = B.bmi
AND A.smoker != B.smoker 
AND A.children = B.children;


-- Issue 1: This query calculates the average of row-level claim differences instead of the difference between smoker and non-smoker average claims.
-- Issue 2: Self-joining causes multiple random pairings between smokers and non-smokers with the same BMI and children, leading to incorrect results.
-- Issue 3: The query does not clearly distinguish which records belong to smokers and which to non-smokers.
-- Issue 4: Aggregation is applied after subtraction, whereas the correct approach is to aggregate first and then compute the difference.

-- Updated Solution:

-- We need to find the difference in average claims by Somker and non-smokers having the same BMI
--  and Children.

SELECT bmi, children, AVG(claim) AS smoker_avg_claim, (
    SELECT AVG(claim)
    FROM insurance_data AS non_smoker
    WHERE non_smoker.bmi = smoker.bmi
    AND non_smoker.children = smoker.children
    AND non_smoker.smoker = 'No'
) AS non_smoker_avg_claim, AVG(claim) - (
    SELECT AVG(claim)
    FROM insurance_data AS non_smoker
    WHERE non_smoker.bmi = smoker.bmi
    AND non_smoker.children = smoker.children
    AND non_smoker.smoker = 'No'
) AS claim_diff
FROM insurance_data AS smoker
WHERE smoker.smoker = 'Yes'
GROUP BY smoker.bmi, smoker.children
having claim_diff is not null
ORDER BY bmi, children;

-- answer format be like 
-- bmi | children | smoker_avg_claim | non_smoker_avg_claim | claim_diff

