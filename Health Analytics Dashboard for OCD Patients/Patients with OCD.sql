
CREATE DATABASE PatientDataset;


-- Count & Pct of M vs F that have OCD & -- Average Obsession Score by Gender

-- Create a temporary table
SELECT 
    GENDER,
    COUNT([Patient_ID]) AS patient_count,
    AVG([Y_BOCS_Score_Obsessions]) AS ave_bs_score
INTO 
	#temp_data1
FROM 
    [dbo].[ocd_patient_dataset]
GROUP BY 
    GENDER;

-- First query
SELECT * 
FROM 
	#temp_data1
ORDER BY 
	patient_count;

-- Second query
SELECT
    SUM(CASE WHEN Gender = 'Female' THEN patient_count ELSE 0 END) AS count_female,
    SUM(CASE WHEN Gender = 'Male' THEN patient_count ELSE 0 END) AS count_male,

    ROUND(CAST(SUM(CASE WHEN Gender = 'Male' THEN patient_count ELSE 0 END) AS FLOAT)/
    CAST((SUM(CASE WHEN Gender = 'Male' THEN patient_count ELSE 0 END) + SUM(CASE WHEN Gender = 'Female' THEN patient_count ELSE 0 END)) AS FLOAT) *100,2)
    AS pct_male,
	ROUND(CAST(SUM(CASE WHEN Gender = 'Female' THEN patient_count ELSE 0 END) AS FLOAT)/
    CAST((SUM(CASE WHEN Gender = 'Female' THEN patient_count ELSE 0 END) + SUM(CASE WHEN Gender = 'Male' THEN patient_count ELSE 0 END)) AS FLOAT) *100,2)
    AS pct_female
FROM
    #temp_data1;

-- Drop the temporary table after use
DROP TABLE
	#temp_data1
	;


-- Count of Patients by Ethnicities and their respective Average Obsession Score
SELECT
	[Ethnicity],
	COUNT([Patient_ID]) AS patient_count,
	AVG([Y_BOCS_Score_Obsessions]) AS obs_score
FROM 
	[dbo].[ocd_patient_dataset]
GROUP BY
	[Ethnicity]
ORDER BY
	obs_score
	;


-- Number of people diagnosed with OCD MoM
ALTER TABLE [dbo].[ocd_patient_dataset]
ALTER COLUMN [OCD_Diagnosis_Date] date;

SELECT
    FORMAT([OCD_Diagnosis_Date], 'yyyy-MM-01 00:00:00') AS month,
    COUNT([Patient_ID]) AS patient_count
FROM 
    [dbo].[ocd_patient_dataset]
GROUP BY 
    FORMAT([OCD_Diagnosis_Date], 'yyyy-MM-01 00:00:00')
ORDER BY 
    month
	;

--What is the most common Obsession Type (Count) & it's respective Average Obsession Score
SELECT
	[Obsession_Type],
	COUNT('Patient_ID') AS patient_count,
    ROUND(AVG(CAST([Y_BOCS_Score_Obsessions] AS FLOAT)),2) AS obs_score  -- Convert varchar to float
FROM 
	[dbo].[ocd_patient_dataset]
GROUP BY 
	[Obsession_Type]
ORDER BY 
	patient_count
	;

-- What is the most common Comulsion type (Count) and it's respective Average Obsession Score
SELECT
	[Compulsion_Type],
	COUNT('Patient_ID') AS patient_count,
    ROUND(AVG(CAST([Y_BOCS_Score_Obsessions] AS FLOAT)),2) AS obs_score  -- Convert varchar to float
FROM 
	[dbo].[ocd_patient_dataset]
GROUP BY 
	[Compulsion_Type]
ORDER BY 
	patient_count
	;