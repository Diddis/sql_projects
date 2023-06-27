/*
Dr. Carla Patalano and Dr. Rich Huebner are the original authors of this synthetic 
dataset (New England College of Business).

This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivatives 
4.0 International License.CC-BY-NC-ND

This project focuses on exploring the relationship between employee retention
and employee and job characteristics. Specifically, the following questions will
be explored:

1. How many employees have terminated their employment (voluntary or involuntary)?
2. How are job performance scores related to termination?
3. How are employee satisfaction scores related to termination?
4. Do any particular departments have higher employee terminations?

The database consists of three tables: characteristics of employees, job and 
satisfaction scores, and job status. 
*/


--How many employees are currently in the database? (check for dups)
SELECT 
	COUNT(*) AS 'nu. records', 
	COUNT(DISTINCT EmpID) AS 'nu. distinct employees'
FROM HR_Employees;

--What time period does this database cover?
SELECT 
	MIN(DateofHire) AS 'first hire', 
	MAX(DateofHire) AS 'last hire', 
	MAX(DateofTermination) AS 'last termination'
FROM HR_Status;

--Generate a new field for how long an employee has worked at the company
--from the date of hire and termination, since this might correlate with retention.
--Since these are fake data, we will pretend the current date is 2018-12-31.
--Note: SQL Server auto generated NULL values as 1899-12-30 since DATETIME field cannot be NULL

--Add field if it does not already exist.
IF COL_LENGTH('dbo.HR_Status', 'MonthsEmployed') IS NULL
	ALTER TABLE HR_Status
	ADD MonthsEmployed INT
ELSE PRINT 'Column exists';

--Add months employed column from date of hire and date of termination (or current fake date)
UPDATE HR_Status
  SET MonthsEmployed = 
	CASE
		WHEN DateofTermination = '1899-12-30 00:00:00.000' THEN DATEDIFF(month, DateofHire, '12/31/2018')
		ELSE DATEDIFF(month, DateofHire, DateofTermination) 
	END;

--Q1
--How many employees have terminated their employment (voluntary or involuntary)?
SELECT 
	EmploymentStatus, 
	COUNT(*) AS 'count',
	ROUND((COUNT(*) * 1.0 / (SELECT COUNT(*) FROM HR_Status) * 100.0), 2)  AS 'percentage',
	AVG(MonthsEmployed) AS 'ave. nu. months employed'
FROM HR_Status
GROUP BY EmploymentStatus
ORDER BY COUNT(*) DESC;

--What are the most common reasons cited for terminating for cause?
SELECT
	TermReason AS 'reason, for cause',
	COUNT(*) AS 'count'
FROM HR_Status
WHERE EmploymentStatus='Terminated for Cause'
GROUP BY TermReason
ORDER BY COUNT(*) DESC;

--What are the most common reasons cited for voluntarily leaving?
SELECT
	TermReason AS 'reason, voluntary',
	COUNT(*) AS 'count'
FROM HR_Status
WHERE EmploymentStatus='Voluntarily Terminated'
GROUP BY TermReason
ORDER BY COUNT(*) DESC;

--Q2 & Q3
--How does employment status relate to employee satisfaction and job engagement scores?
SELECT 
	HR_Status.EmploymentStatus, 
	AVG(HR_Scores.EngagementSurvey) AS 'ave. engagement',
	AVG(HR_Scores.Absences) AS 'ave. absences',
	AVG(HR_Scores.EmpSatisfaction) AS 'ave. satisfaction',
	AVG(HR_Scores.SpecialProjectsCount) AS 'ave. special projects'
FROM HR_Scores
LEFT JOIN HR_Status
ON HR_Scores.EmpID = HR_Status.EmpID
GROUP BY HR_Status.EmploymentStatus
ORDER BY COUNT(HR_Status.EmploymentStatus) DESC;

--Average number of special projects is at 1 and 0. Check the field to make sure it is not a flaw.
SELECT 
	SpecialProjectsCount, 
	COUNT(*) AS 'count'
FROM HR_Scores
GROUP BY SpecialProjectsCount
ORDER BY SpecialProjectsCount;

--Q4
--Do any particular departments have higher employee terminations?
SELECT 
	HR_Employees.Department, 
	COUNT(*) AS 'total count',
	COUNT(CASE HR_Status.EmploymentStatus WHEN 'Active' THEN 1 ELSE NULL END) AS 'active',
	COUNT(CASE HR_Status.EmploymentStatus WHEN 'Voluntarily Terminated' THEN 1 ELSE NULL END) AS 'voluntary',
	COUNT(CASE HR_Status.EmploymentStatus WHEN 'Terminated for Cause' THEN 1 ELSE NULL END) AS 'for cause'
FROM HR_Employees
LEFT JOIN HR_Status
ON HR_Employees.EmpID = HR_Status.EmpID
GROUP BY HR_Employees.Department; 

--Do employees from any particular recruitment source have higher employee terminations?
SELECT 
	HR_Employees.RecruitmentSource, 
	COUNT(*) AS 'total count',
	COUNT(CASE HR_Status.EmploymentStatus WHEN 'Active' THEN 1 ELSE NULL END) AS 'active',
	COUNT(CASE HR_Status.EmploymentStatus WHEN 'Voluntarily Terminated' THEN 1 ELSE NULL END) AS 'voluntary',
	COUNT(CASE HR_Status.EmploymentStatus WHEN 'Terminated for Cause' THEN 1 ELSE NULL END) AS 'for cause'
FROM HR_Employees
LEFT JOIN HR_Status
ON HR_Employees.EmpID = HR_Status.EmpID
GROUP BY HR_Employees.RecruitmentSource; 

/*
SUMMARY

This exploratory data analysis in SQL revealed a few descriptive patterns.

1. Of the 311 total employees employed between January 2006 and November 2018, 28% 
   voluntarily left and 5% were terminated for cause. The most common reasons for 
   terminating for cause were attendance issues, no-show without calling, and performance,
   in that order. For those leaving voluntarily, most left for another position, however,
   many also left because they were unhappy or wanted higher income.
2. Employees who left voluntarily had slightly higher average engagement scores and fewer
   special projects to work on, suggesting there could be a discrepancy between high 
   performance employees and providing interesting and challenging work. This could be 
   explored further. Meanwhile, employees terminated for cause had lower engagement scores
   and higher average absences than active or voluntarily terminated employees.
3. A few deparmtents had lower retention of employees, but it is difficult to draw conclusions
   without further statistical analyses to see if the between group differences are significant.

Notes: additional statistical analyses are required to learn more about whether there
are real differences between employees who left voluntarily, involuntarily, and those who 
remained employed.
*/