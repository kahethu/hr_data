# HR DATA ANALYSIS - SQL SERVER 2022 / POWER BI
This project allowed me to dive deep into the realm of data analysis to uncover important insights that can greatly benefit the company.
## Source Data:
The source data contained Human Resource 22000 records from 2000 to 2020. This is included in the repository.

## Data Cleaning & Analysis:
This was done on SQL server 2022 involving
- Data loading & inspection
- Handling missing values
- Data cleaning and analysis

## Data Visualization:
Power BI:

![HR report_Page_1](https://github.com/kahethu/data/assets/27964625/89069bbe-eaf3-4f54-9140-d75683d175ce)

![HR report_Page_2](https://github.com/kahethu/data/assets/27964625/b793c637-7020-4aa3-ab38-0f88dcc5037d)


## Exploratory Data Analysis
### Questions:
1)	What's the gender breakdown in the company?
2)	How does gender vary across departments and job titles?
3)	What's the age distribution in the company?
4)	What's the race distribution in the company?
5)	What's the average length of employment in the company?
6)	Which department has the highest turnover rate?
7)	What is the tenure distribution for each department?
8)	How many employees work remotely for each department?
9)	What's the distribution of employees across different states?
10)	How are job titles distributed in the company?

### Findings:
1)	There are more male employees than female or non-conforming employees.
2)	The genders are fairly evenly distributed across departments. There are slightly more male employees overall.
3)	Employees 21-30 years old are the fewest in the company. Most employees are 31-50 years old. Surprisingly, the age group 50+ have the most employees in the company.
4)	Caucasian employees are the majority in the company, followed by mixed race, black, Asian, Hispanic, and native Americans.
5)	The average length of employment is 10 years.
6)	Auditing has the highest turnover rate, followed by Legal, Research & Development and Training. Business Development & Marketing have the lowest turnover rates.
7)	Surprisingly employees tend to stay with the company for decades, ranging from 32-41 years. Tenure is quite evenly distributed across departments.
8)	About 25% of employees work remotely.
9)	Most employees are in Ohio (14,788) followed distantly by Pennsylvania (930) and Illinois (730), Indiana (572), Michigan (569), Kentucky (375) and Wisconsin (321).

### 1) Create Database
``` SQL
CREATE DATABASE Human_Resources
```
### 2) Import Data to SQL Server
- Right-click on Human_Resources > Tasks > Import Data
- Use import wizard to import HR Data.csv to hr table
- Verify that the import worked:

``` SQL
use Human_Resources
```
``` SQL
SELECT *
FROM hr_data;
```

### 3) Data Cleaning
The termdate was imported as nvarchar(50). This column contains termination dates, hence it needs to be converted to the date format.

####	Update date/time to date
![format-termdate-1](https://github.com/kahethu/data/assets/27964625/463e86e0-8b1a-47c8-943e-f125bad98706)

``` SQL
UPDATE hr_data
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19), 120), 'yyyy-MM-dd');
```
#### Change NULL values to 0000-00-00
``` SQL
UPDATE hr_data
SET termdate = '0000-00-00'
WHERE termdate IS NULL;
```

This reformats the dates like this:

![termdate-transformed](https://github.com/kahethu/data/assets/27964625/c59c8f2f-f292-4a18-918f-0db4b9c0b337)

#### Update from nvachar to date
- First, add a new date column
``` SQL
ALTER TABLE hr_data
ADD new_termdate DATE;
```
- Update the new date column with the converted values

``` SQL
UPDATE hr_data
SET new_termdate = CASE
    WHEN termdate IS NOT NULL AND ISDATE(termdate) = 1
        THEN CAST(termdate AS DATETIME)
    WHEN termdate IS NULL
        THEN '000-00-00'
    ELSE NULL
    END;
```
new_termdate column is loaded, 0000-00-00 converted to NULL values
![new_termdate](https://github.com/kahethu/data/assets/27964625/56f805d8-5f99-42b0-8e56-02d9efd78721)

#### create new column "age"
``` SQL
ALTER TABLE hr_data
ADD age nvarchar(50)
```

#### populate new column with age
``` SQL
UPDATE hr_data
SET age = DATEDIFF(YEAR, birthdate, GETDATE());
```

## QUESTIONS TO ANSWER FROM THE DATA

#### 1) What's the gender breakdown in the company?

``` SQL
SELECT
 gender,
 COUNT(gender) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender ASC;
```
#### 2) How does gender vary across departments and job titles?

``` SQL
SELECT department, gender, count(*) as count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY department, gender
ORDER BY department;
```

#### 3) What's the age distribution in the company?
``` SQL
SELECT 
 MIN(age) AS Youngest, 
 MAX(age) AS Oldest
FROM hr_data;
```

- age distribution 
``` SQL
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
```

- age group by gender

``` SQL
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
```

#### 4) What's the race distribution in the company?
``` SQL
SELECT race,
 COUNT(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY race
ORDER BY count DESC;
```

#### 5) What's the average length of employment in the company?
``` SQL
SELECT
 AVG(DATEDIFF(year, hire_date, new_termdate)) AS tenure
 FROM hr_data
 WHERE new_termdate IS NOT NULL;
```

#### 6) Which department has the highest turnover rate?
``` SQL
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
```



#### 7) What is the tenure distribution for each department?
``` SQL
SELECT 
 department, DATEDIFF(year, MIN(hire_date), MAX(new_termdate)) AS tenure
FROM hr_data
WHERE  new_termdate IS NOT NULL
GROUP BY department
ORDER BY tenure DESC;
```

#### 8) How many employees work remotely for each department?
``` SQL
SELECT
 location,
 count(*) AS count
 FROM hr_data
 WHERE new_termdate IS NULL
 GROUP BY location;
```

#### 9) What's the distribution of employees across different states?
``` SQL
SELECT
location_state,
count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;
```

#### 10) How are job titles distributed in the company?
``` SQL
SELECT 
 jobtitle,
 count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY jobtitle
ORDER BY count DESC;
```

#### 11) How have hire counts varied over time?
``` SQL
SELECT
    hire_yr,
    hires,
    terminations,
    hires - terminations AS net_change,
    (round(CAST(hires - terminations AS FLOAT) / NULLIF(hires, 0), 2)) *100 AS percent_hire_change
FROM  
    (SELECT
        YEAR(hire_date) AS hire_yr,
        COUNT(*) AS hires,
        SUM(CASE WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0 END) terminations
    FROM hr_data
    GROUP BY YEAR(hire_date)
    ) AS subquery
ORDER BY hire_yr ASC;
```
