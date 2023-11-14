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
Power BI

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

####	Update date/time to date
``` SQL
UPDATE hr_data
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19), 120), 'yyyy-MM-dd');
```

