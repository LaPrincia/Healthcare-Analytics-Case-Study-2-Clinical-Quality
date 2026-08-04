/*====================================================================
  PALMETTO REGIONAL HEALTH SYSTEM

  CASE STUDY 2:
  CLINICAL QUALITY & PERFORMANCE IMPROVEMENT

  DASHBOARD PAGE 1:
  CLINICAL QUALITY PERFORMANCE

  FILE:
  02_CS2_Clinical_Quality_Performance_Validation.sql

  PURPOSE:
  Validate the final Clinical Quality Performance dataset before
  exporting it to CSV and importing it into Microsoft Power BI.

  DATASET:
  dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
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
      'PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset';
GO


/*====================================================================
  SECTION 3
  REVIEW THE FIRST 25 DATASET RECORDS
====================================================================*/

SELECT TOP 25
    *
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
ORDER BY
    Dataset_Row_ID;
GO


/*====================================================================
  SECTION 4
  VALIDATE THE TOTAL NUMBER OF DATASET ROWS
====================================================================*/

SELECT
    COUNT(*) AS Total_Dataset_Rows
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset;
GO


/*====================================================================
  SECTION 5
  VALIDATE THE NUMBER OF UNIQUE PATIENTS

  One patient may appear more than once because the dataset contains
  one row per patient per quality measure.
====================================================================*/

SELECT
    COUNT(DISTINCT Patient_ID) AS Unique_Patients
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset;
GO


/*====================================================================
  SECTION 6
  VALIDATE DATASET ROW IDENTIFIERS

  The total row count and distinct Dataset_Row_ID count should match.
====================================================================*/

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Dataset_Row_ID) AS Distinct_Dataset_Row_IDs
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset;
GO


/*====================================================================
  SECTION 7
  CHECK FOR DUPLICATE PATIENT AND QUALITY-MEASURE RECORDS

  This query should return no rows after Population_Health has been
  deduplicated in the Page 1 query.
====================================================================*/

SELECT
    Patient_ID,
    Measure_Name,
    Measure_Category,
    Reporting_Period,
    COUNT(*) AS Duplicate_Record_Count
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
GROUP BY
    Patient_ID,
    Measure_Name,
    Measure_Category,
    Reporting_Period
HAVING COUNT(*) > 1
ORDER BY
    Duplicate_Record_Count DESC,
    Patient_ID,
    Measure_Name;
GO


/*====================================================================
  SECTION 8
  CHECK REQUIRED FIELDS FOR NULL VALUES
====================================================================*/

SELECT
    SUM(CASE WHEN Dataset_Row_ID IS NULL THEN 1 ELSE 0 END)
        AS Null_Dataset_Row_IDs,

    SUM(CASE WHEN Patient_ID IS NULL THEN 1 ELSE 0 END)
        AS Null_Patient_IDs,

    SUM(CASE WHEN Measure_Name IS NULL THEN 1 ELSE 0 END)
        AS Null_Measure_Names,

    SUM(CASE WHEN Measure_Category IS NULL THEN 1 ELSE 0 END)
        AS Null_Measure_Categories,

    SUM(CASE WHEN Reporting_Period IS NULL THEN 1 ELSE 0 END)
        AS Null_Reporting_Periods,

    SUM(CASE WHEN Target_Value IS NULL THEN 1 ELSE 0 END)
        AS Null_Target_Values,

    SUM(CASE WHEN Actual_Value IS NULL THEN 1 ELSE 0 END)
        AS Null_Actual_Values,

    SUM(CASE WHEN Met_Target IS NULL THEN 1 ELSE 0 END)
        AS Null_Met_Target_Values

FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset;
GO


/*====================================================================
  SECTION 9
  REVIEW QUALITY MEASURE CATEGORIES
====================================================================*/

SELECT
    Measure_Category,
    COUNT(*) AS Dataset_Rows,
    COUNT(DISTINCT Patient_ID) AS Unique_Patients
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
GROUP BY
    Measure_Category
ORDER BY
    Measure_Category;
GO


/*====================================================================
  SECTION 10
  REVIEW QUALITY MEASURES
====================================================================*/

SELECT
    Measure_Category,
    Measure_Name,
    COUNT(*) AS Dataset_Rows,
    COUNT(DISTINCT Patient_ID) AS Unique_Patients
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
GROUP BY
    Measure_Category,
    Measure_Name
ORDER BY
    Measure_Category,
    Measure_Name;
GO


/*====================================================================
  SECTION 11
  REVIEW REPORTING PERIODS
====================================================================*/

SELECT
    Reporting_Period,
    COUNT(*) AS Dataset_Rows,
    COUNT(DISTINCT Patient_ID) AS Unique_Patients
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
GROUP BY
    Reporting_Period
ORDER BY
    Reporting_Period;
GO


/*====================================================================
  SECTION 12
  REVIEW QUALITY PERFORMANCE AGAINST TARGET
====================================================================*/

SELECT
    Measure_Category,
    Measure_Name,
    Reporting_Period,

    CAST(AVG(Target_Value) AS DECIMAL(10,2))
        AS Average_Target_Value,

    CAST(AVG(Actual_Value) AS DECIMAL(10,2))
        AS Average_Actual_Value,

    CAST(AVG(Variance_To_Target) AS DECIMAL(10,2))
        AS Average_Variance_To_Target

FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
GROUP BY
    Measure_Category,
    Measure_Name,
    Reporting_Period
ORDER BY
    Measure_Category,
    Measure_Name,
    Reporting_Period;
GO


/*====================================================================
  SECTION 13
  REVIEW MET-TARGET RESULTS
====================================================================*/

SELECT
    Met_Target,
    COUNT(*) AS Quality_Measure_Records,
    COUNT(DISTINCT Patient_ID) AS Unique_Patients
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
GROUP BY
    Met_Target
ORDER BY
    Met_Target;
GO


/*====================================================================
  SECTION 14
  REVIEW PERFORMANCE STATUS
====================================================================*/

SELECT
    Performance_Status,
    COUNT(*) AS Quality_Measure_Records,
    COUNT(DISTINCT Patient_ID) AS Unique_Patients
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
GROUP BY
    Performance_Status,
    Performance_Status_Sort
ORDER BY
    Performance_Status_Sort;
GO


/*====================================================================
  SECTION 15
  REVIEW PERFORMANCE IMPROVEMENT OPPORTUNITIES
====================================================================*/

SELECT
    Improvement_Opportunity,
    COUNT(*) AS Quality_Measure_Records,
    COUNT(DISTINCT Patient_ID) AS Unique_Patients
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
GROUP BY
    Improvement_Opportunity,
    Improvement_Opportunity_Sort
ORDER BY
    Improvement_Opportunity_Sort;
GO


/*====================================================================
  SECTION 16
  REVIEW PATIENT RISK DISTRIBUTION
====================================================================*/

SELECT
    Risk_Level,
    COUNT(DISTINCT Patient_ID) AS Unique_Patients
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
GROUP BY
    Risk_Level,
    Risk_Level_Sort
ORDER BY
    Risk_Level_Sort;
GO


/*====================================================================
  SECTION 17
  REVIEW CHRONIC CONDITION GROUPS
====================================================================*/

SELECT
    Chronic_Condition_Group,
    COUNT(DISTINCT Patient_ID) AS Unique_Patients
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
GROUP BY
    Chronic_Condition_Group,
    Chronic_Condition_Group_Sort
ORDER BY
    Chronic_Condition_Group_Sort;
GO


/*====================================================================
  SECTION 18
  VALIDATE CARE-GAP, READMISSION, AND HIGH-RISK PATIENT COUNTS
====================================================================*/

SELECT
    COUNT
    (
        DISTINCT
        CASE
            WHEN Care_Gap_Flag = 1
                THEN Patient_ID
        END
    ) AS Patients_With_Care_Gaps,

    COUNT
    (
        DISTINCT
        CASE
            WHEN Readmission_30_Day_Flag = 1
                THEN Patient_ID
        END
    ) AS Patients_With_30_Day_Readmissions,

    COUNT
    (
        DISTINCT
        CASE
            WHEN High_Risk_Flag = 1
                THEN Patient_ID
        END
    ) AS High_Risk_Patients

FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset;
GO


/*====================================================================
  SECTION 19
  REVIEW PREVENTIVE CARE RESULTS
====================================================================*/

SELECT
    COUNT
    (
        DISTINCT
        CASE
            WHEN Preventive_Screening_Complete_Flag = 1
                THEN Patient_ID
        END
    ) AS Preventive_Screening_Complete,

    COUNT
    (
        DISTINCT
        CASE
            WHEN Preventive_Screening_Overdue_Flag = 1
                THEN Patient_ID
        END
    ) AS Preventive_Screening_Overdue,

    COUNT
    (
        DISTINCT
        CASE
            WHEN Flu_Vaccine_Compliant_Flag = 1
                THEN Patient_ID
        END
    ) AS Flu_Vaccine_Compliant,

    COUNT
    (
        DISTINCT
        CASE
            WHEN Colonoscopy_Complete_Flag = 1
                THEN Patient_ID
        END
    ) AS Colonoscopy_Complete,

    COUNT
    (
        DISTINCT
        CASE
            WHEN Mammogram_Complete_Flag = 1
                THEN Patient_ID
        END
    ) AS Mammogram_Complete,

    COUNT
    (
        DISTINCT
        CASE
            WHEN A1C_Controlled_Flag = 1
                THEN Patient_ID
        END
    ) AS A1C_Controlled

FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset;
GO


/*====================================================================
  SECTION 20
  CHECK NUMERIC VALUE RANGES

  This query should return no rows because Target_Value and Actual_Value
  are expected to remain between zero and one hundred.
====================================================================*/

SELECT
    Dataset_Row_ID,
    Patient_ID,
    Measure_Name,
    Target_Value,
    Actual_Value,
    Percent_Of_Target_Achieved
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
WHERE Target_Value < 0
   OR Actual_Value < 0
   OR Target_Value > 100
   OR Actual_Value > 100
ORDER BY
    Dataset_Row_ID;
GO


/*====================================================================
  SECTION 21
  FINAL VALIDATION SUMMARY
====================================================================*/

SELECT
    COUNT(*) AS Total_Dataset_Rows,

    COUNT(DISTINCT Dataset_Row_ID)
        AS Distinct_Dataset_Row_IDs,

    COUNT(DISTINCT Patient_ID)
        AS Unique_Patients,

    COUNT(DISTINCT Measure_Name)
        AS Unique_Quality_Measures,

    COUNT(DISTINCT Measure_Category)
        AS Unique_Measure_Categories,

    COUNT(DISTINCT Reporting_Period)
        AS Unique_Reporting_Periods

FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset;
GO