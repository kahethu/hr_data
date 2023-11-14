CREATE DATABASE Human_Resources
use Human_Resources

SELECT *
FROM hr_data;

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'hr_data';

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'hr_data';


-- Fix column "termdate" formatting

SELECT termdate
FROM hr_data


-- format termdate datetime UTC values
-- Update date/time to date
UPDATE hr_data
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19), 120), 'yyyy-MM-dd');


-- Update NULL to 0000-00-00
UPDATE hr_data
SET termdate = '0000-00-00'
WHERE termdate IS NULL;

-- Update from nvachar to date
-- First, add a new date column
ALTER TABLE hr_data
ADD new_termdate DATE;

-- Update the new date column with the converted values
-- retains the NULL values
UPDATE hr_data
SET new_termdate = CASE
    WHEN termdate IS NOT NULL AND ISDATE(termdate) = 1
        THEN CAST(termdate AS DATETIME)
    WHEN termdate IS NULL
        THEN '000-00-00'
    ELSE NULL
    END;

SELECT new_termdate
FROM hr_data;

-- create new column "age"
ALTER TABLE hr_data
ADD age nvarchar(50)

SELECT age
FROM hr_data;

-- populate new column with age
UPDATE hr_data
SET age = DATEDIFF(YEAR, birthdate, GETDATE());

SELECT birthdate, age
FROM hr_data;

-- min and max ages
SELECT 
 MIN(age) AS min_age, 
 MAX(AGE) AS max_age
FROM hr_data;

-- QUESTIONS TO ANSWER FROM THE DATA

-- 1) What's the gender breakdown in the company?

SELECT
 gender,
 COUNT(gender) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender ASC;

-- 2) How does gender vary across departments and job titles?


SELECT department, gender, count(*) as count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY department, gender
ORDER BY department;


-- 3) What's the age distribution in the company?
SELECT 
 MIN(age) AS Youngest, 
 MAX(age) AS Oldest
FROM hr_data;

-- age distribution 

SELECT
  age_group,
  COUNT(*) AS count
FROM (
  SELECT
    CASE
      WHEN age <= 21 AND age <= 30 THEN '21 to 30'
      WHEN age <= 31 AND age <= 40 THEN '31 to 40'
      WHEN age <= 41 AND age <= 50 THEN '41-50'
      ELSE '50+'
    END AS age_group
  FROM hr_data
  WHERE new_termdate IS NULL
) AS Subquery
GROUP BY age_group
ORDER BY age_group;

-- age group by gender

SELECT
  age_group,
  gender,
  COUNT(*) AS count
FROM (
  SELECT
    CASE
      WHEN age <= 21 AND age <= 30 THEN '21 to 30'
      WHEN age <= 31 AND age <= 40 THEN '31 to 40'
      WHEN age <= 41 AND age <= 50 THEN '41-50'
      ELSE '50+'
    END AS age_group,
	gender
  FROM hr_data
  WHERE new_termdate IS NULL
) AS Subquery
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4) What's the race distribution in the company?
SELECT race,
 COUNT(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY race
ORDER BY count DESC;


-- 5) What's the average length of employment in the company?
SELECT
 AVG(DATEDIFF(year, hire_date, new_termdate)) AS tenure
 FROM hr_data
 WHERE new_termdate IS NOT NULL;

-- 6) Which department has the highest turnover rate?

SELECT
 department,
 total_count,
 terminated_count,
 round(CAST(terminated_count AS FLOAT)/total_count, 2) AS turnover_rate
FROM 
   (SELECT
   department,
   count(*) AS total_count,
   SUM(CASE
        WHEN new_termdate IS NOT NULL AND new_termdate <= getdate()
		THEN 1 ELSE 0
		END
   ) AS terminated_count
  FROM hr_data
  GROUP BY department
  ) AS Subquery
ORDER BY turnover_rate DESC;




-- 7) What is the tenure distribution for each department?

SELECT 
 department, DATEDIFF(year, MIN(hire_date), MAX(new_termdate)) AS tenure
FROM hr_data
WHERE  new_termdate IS NOT NULL
GROUP BY department
ORDER BY tenure DESC;

-- 8) How many employees work remotely for each department?
SELECT
 location,
 count(*) AS count
 FROM hr_data
 WHERE new_termdate IS NULL
 GROUP BY location;

-- 9) What's the distribution of employees across different states?
SELECT
location_state,
count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;


-- 10) How are job titles distributed in the company?
SELECT 
 jobtitle,
 count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY jobtitle
ORDER BY count DESC;

