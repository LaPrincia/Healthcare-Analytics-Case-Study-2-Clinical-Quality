/*====================================================================
  PALMETTO REGIONAL HEALTH SYSTEM

  CASE STUDY 2:
  CLINICAL QUALITY & PERFORMANCE IMPROVEMENT

  DASHBOARD PAGE 2:
  PATIENT RISK & POPULATION INSIGHTS

  FILE:
  05_CS2_Patient_Risk_Population_Validation.sql

  PURPOSE:
  Validate the final Patient Risk & Population Insights dataset before
  exporting it to CSV and importing it into Microsoft Power BI.

  DATASET:
  dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
====================================================================*/


/*====================================================================
  SECTION 1
  SELECT THE PROJECT DATABASE
====================================================================*/

USE PalmettoRegionalHealthSystemDW;
GO


/*====================================================================
  SECTION 2
  CONFIRM THE DATASET EXISTS
====================================================================*/

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME =
      'PRHS_CS2_Page2_Patient_Risk_Population_Dataset';
GO


/*====================================================================
  SECTION 3
  REVIEW THE FIRST 25 RECORDS
====================================================================*/

SELECT TOP 25
    *
FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
ORDER BY
    Dataset_Row_ID;
GO


/*====================================================================
  SECTION 4
  VALIDATE TOTAL ROWS
====================================================================*/

SELECT
    COUNT(*) AS Total_Dataset_Rows
FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset;
GO


/*====================================================================
  SECTION 5
  VALIDATE UNIQUE PATIENTS

  Because this dataset contains one row per patient, both values
  should be identical.
====================================================================*/

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Patient_ID) AS Unique_Patients
FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset;
GO


/*====================================================================
  SECTION 6
  CHECK FOR DUPLICATE PATIENTS

  This query should return no rows.
====================================================================*/

SELECT
    Patient_ID,
    COUNT(*) AS Duplicate_Record_Count
FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
GROUP BY
    Patient_ID
HAVING COUNT(*) > 1;
GO


/*====================================================================
  SECTION 7
  CHECK REQUIRED FIELDS FOR NULL VALUES
====================================================================*/

SELECT

    SUM(CASE WHEN Dataset_Row_ID IS NULL THEN 1 ELSE 0 END)
        AS Null_Dataset_Row_IDs,

    SUM(CASE WHEN Patient_ID IS NULL THEN 1 ELSE 0 END)
        AS Null_Patient_IDs,

    SUM(CASE WHEN Risk_Level IS NULL THEN 1 ELSE 0 END)
        AS Null_Risk_Level,

    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END)
        AS Null_Age,

    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END)
        AS Null_Gender

FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset;
GO


/*====================================================================
  SECTION 8
  REVIEW RISK LEVEL DISTRIBUTION
====================================================================*/

SELECT
    Risk_Level,
    COUNT(*) AS Patients
FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
GROUP BY
    Risk_Level,
    Risk_Level_Sort
ORDER BY
    Risk_Level_Sort;
GO


/*====================================================================
  SECTION 9
  REVIEW AGE GROUPS
====================================================================*/

SELECT
    Age_Group,
    COUNT(*) AS Patients
FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
GROUP BY
    Age_Group,
    Age_Group_Sort
ORDER BY
    Age_Group_Sort;
GO


/*====================================================================
  SECTION 10
  REVIEW CHRONIC CONDITION GROUPS
====================================================================*/

SELECT
    Chronic_Condition_Group,
    COUNT(*) AS Patients
FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
GROUP BY
    Chronic_Condition_Group,
    Chronic_Condition_Group_Sort
ORDER BY
    Chronic_Condition_Group_Sort;
GO


/*====================================================================
  SECTION 11
  REVIEW BMI CATEGORIES
====================================================================*/

SELECT
    BMI_Category,
    COUNT(*) AS Patients
FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
GROUP BY
    BMI_Category,
    BMI_Category_Sort
ORDER BY
    BMI_Category_Sort;
GO


/*====================================================================
  SECTION 12
  REVIEW INTERVENTION PRIORITIES
====================================================================*/

SELECT
    Intervention_Priority,
    COUNT(*) AS Patients
FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
GROUP BY
    Intervention_Priority,
    Intervention_Priority_Sort
ORDER BY
    Intervention_Priority_Sort;
GO


/*====================================================================
  SECTION 13
  REVIEW PREVENTIVE CARE OPPORTUNITIES
====================================================================*/

SELECT
    Preventive_Care_Opportunity_Group,
    COUNT(*) AS Patients
FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
GROUP BY
    Preventive_Care_Opportunity_Group,
    Preventive_Care_Opportunity_Group_Sort
ORDER BY
    Preventive_Care_Opportunity_Group_Sort;
GO


/*====================================================================
  SECTION 14
  REVIEW CARE GAPS
====================================================================*/

SELECT
    Care_Gap,
    COUNT(*) AS Patients
FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
GROUP BY
    Care_Gap
ORDER BY
    Care_Gap;
GO


/*====================================================================
  SECTION 15
  REVIEW READMISSIONS
====================================================================*/

SELECT
    Readmission_30_Days,
    COUNT(*) AS Patients
FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
GROUP BY
    Readmission_30_Days
ORDER BY
    Readmission_30_Days;
GO


/*====================================================================
  SECTION 16
  REVIEW PREVENTIVE CARE STATUS
====================================================================*/

SELECT

    COUNT
    (
        CASE
            WHEN Preventive_Screening_Complete_Flag = 1
                THEN 1
        END
    ) AS Preventive_Screening_Complete,

    COUNT
    (
        CASE
            WHEN Preventive_Screening_Overdue_Flag = 1
                THEN 1
        END
    ) AS Preventive_Screening_Overdue,

    COUNT
    (
        CASE
            WHEN Flu_Vaccine_Compliant_Flag = 1
                THEN 1
        END
    ) AS Flu_Vaccine_Compliant,

    COUNT
    (
        CASE
            WHEN Colonoscopy_Complete_Flag = 1
                THEN 1
        END
    ) AS Colonoscopy_Complete,

    COUNT
    (
        CASE
            WHEN Mammogram_Complete_Flag = 1
                THEN 1
        END
    ) AS Mammogram_Complete,

    COUNT
    (
        CASE
            WHEN A1C_Controlled_Flag = 1
                THEN 1
        END
    ) AS A1C_Controlled

FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset;
GO


/*====================================================================
  SECTION 17
  REVIEW POPULATION RISK SCORE
====================================================================*/

SELECT

    MIN(Population_Risk_Score) AS Minimum_Risk_Score,

    MAX(Population_Risk_Score) AS Maximum_Risk_Score,

    CAST
    (
        AVG(Population_Risk_Score)
        AS DECIMAL(10,2)
    ) AS Average_Risk_Score

FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset;
GO


/*====================================================================
  SECTION 18
  FINAL VALIDATION SUMMARY
====================================================================*/

SELECT

    COUNT(*) AS Total_Patients,

    COUNT(DISTINCT Patient_ID) AS Unique_Patients,

    COUNT(DISTINCT Risk_Level) AS Risk_Levels,

    COUNT(DISTINCT Chronic_Condition_Group)
        AS Chronic_Condition_Groups,

    COUNT(DISTINCT Intervention_Priority)
        AS Intervention_Priorities

FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset;
GO