--------------------------------
-- SQL TASK 7 ------------------
--------------------------------

USE sql_tasks;
SELECT * FROM insurance;

-- 1. What are the top 5 patients who claimed the highest insurance amounts?
SELECT *,DENSE_RANK() OVER(ORDER BY claim DESC) FROM insurance LIMIT 5;

-- 2. What is the average insurance claimed by patients based on the 
--    number of children they have?
SELECT children,avg_claim FROM (SELECT *,
AVG(claim) OVER(PARTITION BY children) AS avg_claim,
ROW_NUMBER() OVER(PARTITION BY children) AS row_num
FROM insurance) t
WHERE t.row_num = 1;


-- 3. What is the highest and lowest claimed amount by patients in each region?
SELECT region,min_claim,max_claim FROM (SELECT *,
MIN(claim) OVER(PARTITION BY region) AS min_claim,
MAX(claim) OVER(PARTITION BY region) AS max_claim,
ROW_NUMBER() OVER(PARTITION BY region) AS row_num
FROM insurance) t
WHERE t.row_num = 1;


-- 5. What is the difference between the claimed amount of each 
--    patient from the claimed amount of the first patient?
SELECT *,
claim - FIRST_VALUE(claim) OVER() AS diff
FROM insurance;

-- 6. For each patient, calculate the difference between their claimed amount 
--    and the average claimed amount of patients with the same number of children.
SELECT *,
claim - AVG(claim) OVER(PARTITION BY children)
FROM insurance;

-- 7. Show the patient with the highest BMI in each region and their 
--    respective overall rank.
SELECT * FROM (SELECT *,
RANK() OVER(PARTITION BY region ORDER BY bmi DESC) AS group_rank,
RANK() OVER(ORDER BY bmi DESC) AS overall_rank
FROM insurance) t
WHERE t.group_rank = 1;

-- 8. Calculate the difference between the claimed amount of each patient 
--    and the claimed amount of the patient who has the highest BMI 
--    in their region.
SELECT *,
claim - FIRST_VALUE(claim) OVER(PARTITION BY region ORDER BY bmi DESC)
FROM insurance;


-- 9. For each patient, calculate the difference in claim amount 
--    between the patient and the patient with the highest claim amount
--    among patients with the smoker status, 
--    within the same region. Return the result in descending order difference.
SELECT *,
(MAX(claim) OVER(PARTITION BY region,smoker) - claim) AS claim_diff
FROM insurance
ORDER BY claim_diff DESC;

-- 10. For each patient, find the maximum BMI value among their next three 
--     records (ordered by age).
SELECT *,
MAX(bmi) OVER(ORDER BY age ROWS BETWEEN 1 FOLLOWING AND 3 FOLLOWING)
FROM insurance;

-- 11. For each patient, find the rolling average of the last 2 claims.
SELECT *,
AVG(claim) OVER(ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING)
FROM insurance;


-- 12. Find the first claimed insurance value for male and female patients, 
--     within each region order the data by patient age in ascending order, 
--     and only include patients who are non-diabetic and have a bmi value 
--     between 25 and 30.
WITH filtered_data AS (
	SELECT * FROM insurance
    WHERE diabetic = 'No' AND bmi BETWEEN 25 AND 30
)

SELECT region,gender,first_claim FROM (SELECT *,
FIRST_VALUE(claim) OVER(PARTITION BY region,gender ORDER BY age) AS first_claim,
ROW_NUMBER() OVER(PARTITION BY region,gender ORDER BY age) AS row_num
FROM filtered_data) t
WHERE t.row_num = 1


