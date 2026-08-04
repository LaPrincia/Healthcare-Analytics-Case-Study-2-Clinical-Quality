/*====================================================================
  PALMETTO REGIONAL HEALTH SYSTEM

  CASE STUDY 2:
  CLINICAL QUALITY & PERFORMANCE IMPROVEMENT

  DASHBOARD PAGE 1:
  CLINICAL QUALITY PERFORMANCE

  FILE:
  01_CS2_Clinical_Quality_Performance_Query.sql

  PLATFORM:
  Microsoft Power BI

  PURPOSE:
  Create an analysis-ready dataset for monitoring clinical quality
  performance, quality-measure compliance, performance against targets,
  care gaps, readmissions, and patient-level quality outcomes.

  SOURCE TABLES:
      dbo.Population_Health
      dbo.Quality_Measures

  FINAL DATASET:
      dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset

  DATA GRAIN:
  One row per patient per quality measure

  DATA QUALITY RULE:
  Population_Health is deduplicated before the join so that only one
  patient-level record is retained for each Patient_ID.
====================================================================*/


/*====================================================================
  SECTION 1
  SELECT THE PROJECT DATABASE
====================================================================*/

USE PalmettoRegionalHealthSystemDW;
GO


/*====================================================================
  SECTION 2
  REMOVE THE PREVIOUS PAGE 1 DATASET
====================================================================*/

DROP TABLE IF EXISTS
    dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset;
GO


/*====================================================================
  SECTION 3
  DEDUPLICATE THE POPULATION HEALTH SOURCE

  ROW_NUMBER assigns a sequence to records sharing the same Patient_ID.
  Only Patient_Record_Rank = 1 will be included in the final dataset.

  This prevents duplicate patient records from multiplying during the
  join to the Quality_Measures table.
====================================================================*/

WITH PopulationHealth_Deduplicated AS
(
    SELECT
        ph.*,

        ROW_NUMBER() OVER
        (
            PARTITION BY ph.Patient_ID
            ORDER BY ph.Patient_ID
        ) AS Patient_Record_Rank

    FROM dbo.Population_Health AS ph
)


/*====================================================================
  SECTION 4
  CREATE THE CLINICAL QUALITY PERFORMANCE DATASET
====================================================================*/

SELECT

    /*================================================================
      DATASET IDENTIFICATION
    ================================================================*/

    ROW_NUMBER() OVER
    (
        ORDER BY
            qm.Reporting_Period,
            qm.Measure_Category,
            qm.Measure_Name,
            ph.Patient_ID
    ) AS Dataset_Row_ID,


    /*================================================================
      PATIENT IDENTIFICATION
    ================================================================*/

    CAST(ph.Patient_ID AS VARCHAR(20)) AS Patient_ID,


    /*================================================================
      PATIENT DEMOGRAPHICS
    ================================================================*/

    ph.Age,

    ph.Gender,

    CASE
        WHEN ph.Age IS NULL THEN 'Unknown'
        WHEN ph.Age < 18 THEN 'Under 18'
        WHEN ph.Age BETWEEN 18 AND 34 THEN '18-34'
        WHEN ph.Age BETWEEN 35 AND 49 THEN '35-49'
        WHEN ph.Age BETWEEN 50 AND 64 THEN '50-64'
        WHEN ph.Age BETWEEN 65 AND 74 THEN '65-74'
        WHEN ph.Age >= 75 THEN '75+'
        ELSE 'Unknown'
    END AS Age_Group,

    CASE
        WHEN ph.Age IS NULL THEN 0
        WHEN ph.Age < 18 THEN 1
        WHEN ph.Age BETWEEN 18 AND 34 THEN 2
        WHEN ph.Age BETWEEN 35 AND 49 THEN 3
        WHEN ph.Age BETWEEN 50 AND 64 THEN 4
        WHEN ph.Age BETWEEN 65 AND 74 THEN 5
        WHEN ph.Age >= 75 THEN 6
        ELSE 0
    END AS Age_Group_Sort,


    /*================================================================
      PATIENT RISK LEVEL
    ================================================================*/

    ph.Risk_Level,

    CASE
        WHEN ph.Risk_Level = 'Low' THEN 1
        WHEN ph.Risk_Level = 'Medium' THEN 2
        WHEN ph.Risk_Level = 'High' THEN 3
        WHEN ph.Risk_Level = 'Very High' THEN 4
        ELSE 0
    END AS Risk_Level_Sort,

    CASE
        WHEN ph.Risk_Level IN ('High', 'Very High') THEN 1
        ELSE 0
    END AS High_Risk_Flag,


    /*================================================================
      CHRONIC CONDITION INFORMATION
    ================================================================*/

    ph.Diabetes,

    ph.Hypertension,

    ph.CHF,

    ph.COPD,

    CASE
        WHEN ph.Diabetes = 'Yes' THEN 1
        ELSE 0
    END AS Diabetes_Flag,

    CASE
        WHEN ph.Hypertension = 'Yes' THEN 1
        ELSE 0
    END AS Hypertension_Flag,

    CASE
        WHEN ph.CHF = 'Yes' THEN 1
        ELSE 0
    END AS CHF_Flag,

    CASE
        WHEN ph.COPD = 'Yes' THEN 1
        ELSE 0
    END AS COPD_Flag,


    /*================================================================
      CHRONIC CONDITION COUNT
    ================================================================*/

    (
        CASE WHEN ph.Diabetes = 'Yes' THEN 1 ELSE 0 END
        +
        CASE WHEN ph.Hypertension = 'Yes' THEN 1 ELSE 0 END
        +
        CASE WHEN ph.CHF = 'Yes' THEN 1 ELSE 0 END
        +
        CASE WHEN ph.COPD = 'Yes' THEN 1 ELSE 0 END
    ) AS Chronic_Condition_Count,

    CASE
        WHEN
        (
            CASE WHEN ph.Diabetes = 'Yes' THEN 1 ELSE 0 END
            +
            CASE WHEN ph.Hypertension = 'Yes' THEN 1 ELSE 0 END
            +
            CASE WHEN ph.CHF = 'Yes' THEN 1 ELSE 0 END
            +
            CASE WHEN ph.COPD = 'Yes' THEN 1 ELSE 0 END
        ) = 0
            THEN 'No Chronic Conditions'

        WHEN
        (
            CASE WHEN ph.Diabetes = 'Yes' THEN 1 ELSE 0 END
            +
            CASE WHEN ph.Hypertension = 'Yes' THEN 1 ELSE 0 END
            +
            CASE WHEN ph.CHF = 'Yes' THEN 1 ELSE 0 END
            +
            CASE WHEN ph.COPD = 'Yes' THEN 1 ELSE 0 END
        ) = 1
            THEN 'One Chronic Condition'

        ELSE 'Multiple Chronic Conditions'
    END AS Chronic_Condition_Group,

    CASE
        WHEN
        (
            CASE WHEN ph.Diabetes = 'Yes' THEN 1 ELSE 0 END
            +
            CASE WHEN ph.Hypertension = 'Yes' THEN 1 ELSE 0 END
            +
            CASE WHEN ph.CHF = 'Yes' THEN 1 ELSE 0 END
            +
            CASE WHEN ph.COPD = 'Yes' THEN 1 ELSE 0 END
        ) = 0
            THEN 1

        WHEN
        (
            CASE WHEN ph.Diabetes = 'Yes' THEN 1 ELSE 0 END
            +
            CASE WHEN ph.Hypertension = 'Yes' THEN 1 ELSE 0 END
            +
            CASE WHEN ph.CHF = 'Yes' THEN 1 ELSE 0 END
            +
            CASE WHEN ph.COPD = 'Yes' THEN 1 ELSE 0 END
        ) = 1
            THEN 2

        ELSE 3
    END AS Chronic_Condition_Group_Sort,


    /*================================================================
      CLINICAL AND LIFESTYLE INFORMATION
    ================================================================*/

    CAST(ph.BMI AS DECIMAL(10,2)) AS BMI,

    CASE
        WHEN ph.BMI IS NULL THEN 'Unknown'
        WHEN ph.BMI < 18.5 THEN 'Underweight'
        WHEN ph.BMI >= 18.5 AND ph.BMI < 25 THEN 'Healthy Weight'
        WHEN ph.BMI >= 25 AND ph.BMI < 30 THEN 'Overweight'
        WHEN ph.BMI >= 30 THEN 'Obese'
        ELSE 'Unknown'
    END AS BMI_Category,

    ph.Smoker,

    CASE
        WHEN ph.Smoker = 'Yes' THEN 1
        ELSE 0
    END AS Smoker_Flag,


    /*================================================================
      PREVENTIVE CARE INFORMATION
    ================================================================*/

    ph.Preventive_Screening,

    ph.Flu_Vaccine,

    ph.Colonoscopy,

    ph.Mammogram,

    ph.A1C_Control,

    CASE
        WHEN ph.Preventive_Screening = 'Complete' THEN 1
        ELSE 0
    END AS Preventive_Screening_Complete_Flag,

    CASE
        WHEN ph.Preventive_Screening = 'Overdue' THEN 1
        ELSE 0
    END AS Preventive_Screening_Overdue_Flag,

    CASE
        WHEN ph.Flu_Vaccine = 'Yes' THEN 1
        ELSE 0
    END AS Flu_Vaccine_Compliant_Flag,

    CASE
        WHEN ph.Colonoscopy = 'Complete' THEN 1
        ELSE 0
    END AS Colonoscopy_Complete_Flag,

    CASE
        WHEN ph.Colonoscopy = 'Overdue' THEN 1
        ELSE 0
    END AS Colonoscopy_Overdue_Flag,

    CASE
        WHEN ph.Mammogram = 'Complete' THEN 1
        ELSE 0
    END AS Mammogram_Complete_Flag,

    CASE
        WHEN ph.Mammogram = 'Overdue' THEN 1
        ELSE 0
    END AS Mammogram_Overdue_Flag,

    CASE
        WHEN ph.A1C_Control = 'Controlled' THEN 1
        ELSE 0
    END AS A1C_Controlled_Flag,

    CASE
        WHEN ph.A1C_Control = 'Uncontrolled' THEN 1
        ELSE 0
    END AS A1C_Uncontrolled_Flag,


    /*================================================================
      PATIENT OUTCOMES AND CARE GAPS
    ================================================================*/

    ph.Readmission_30_Days,

    CASE
        WHEN ph.Readmission_30_Days = 'Yes' THEN 1
        ELSE 0
    END AS Readmission_30_Day_Flag,

    ph.Care_Gap,

    CASE
        WHEN ph.Care_Gap = 'Yes' THEN 1
        ELSE 0
    END AS Care_Gap_Flag,

    CASE
        WHEN ph.Care_Gap = 'No' THEN 1
        ELSE 0
    END AS No_Care_Gap_Flag,


    /*================================================================
      QUALITY MEASURE INFORMATION
    ================================================================*/

    qm.Measure_Name,

    qm.Measure_Category,

    qm.Reporting_Period,

    CAST(qm.Target_Value AS DECIMAL(10,2))
        AS Target_Value,

    CAST(qm.Actual_Value AS DECIMAL(10,2))
        AS Actual_Value,

    qm.Met_Target,

    CASE
        WHEN qm.Met_Target = 'Yes' THEN 1
        ELSE 0
    END AS Met_Target_Flag,

    CASE
        WHEN qm.Met_Target = 'No' THEN 1
        ELSE 0
    END AS Did_Not_Meet_Target_Flag,


    /*================================================================
      QUALITY PERFORMANCE CALCULATIONS
    ================================================================*/

    CAST
    (
        qm.Actual_Value - qm.Target_Value
        AS DECIMAL(10,2)
    ) AS Variance_To_Target,

    CAST
    (
        ABS(qm.Actual_Value - qm.Target_Value)
        AS DECIMAL(10,2)
    ) AS Absolute_Variance_To_Target,

    CAST
    (
        CASE
            WHEN qm.Target_Value IS NULL
                 OR qm.Target_Value = 0
                THEN NULL

            ELSE
                (
                    CAST(qm.Actual_Value AS DECIMAL(18,4))
                    /
                    NULLIF
                    (
                        CAST(qm.Target_Value AS DECIMAL(18,4)),
                        0
                    )
                ) * 100
        END
        AS DECIMAL(10,2)
    ) AS Percent_Of_Target_Achieved,


    /*================================================================
      QUALITY PERFORMANCE STATUS
    ================================================================*/

    CASE
        WHEN qm.Met_Target = 'Yes'
            THEN 'Meeting Target'

        WHEN qm.Met_Target = 'No'
             AND ABS(qm.Actual_Value - qm.Target_Value) <= 5
            THEN 'Near Target'

        ELSE 'Below Target'
    END AS Performance_Status,

    CASE
        WHEN qm.Met_Target = 'Yes' THEN 1

        WHEN qm.Met_Target = 'No'
             AND ABS(qm.Actual_Value - qm.Target_Value) <= 5
            THEN 2

        ELSE 3
    END AS Performance_Status_Sort,


    /*================================================================
      PERFORMANCE IMPROVEMENT OPPORTUNITY
    ================================================================*/

    CASE
        WHEN qm.Met_Target = 'Yes'
            THEN 'Maintain Performance'

        WHEN qm.Met_Target = 'No'
             AND ABS(qm.Actual_Value - qm.Target_Value) <= 5
            THEN 'Monitor Closely'

        ELSE 'Improvement Needed'
    END AS Improvement_Opportunity,

    CASE
        WHEN qm.Met_Target = 'Yes' THEN 3

        WHEN qm.Met_Target = 'No'
             AND ABS(qm.Actual_Value - qm.Target_Value) <= 5
            THEN 2

        ELSE 1
    END AS Improvement_Opportunity_Sort


/*====================================================================
  SECTION 5
  CREATE THE FINAL PAGE 1 DATASET
====================================================================*/

INTO dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset


/*====================================================================
  SECTION 6
  JOIN THE DEDUPLICATED PATIENT DATA TO QUALITY MEASURES
====================================================================*/

FROM PopulationHealth_Deduplicated AS ph

INNER JOIN dbo.Quality_Measures AS qm
    ON ph.Patient_ID = qm.Patient_ID

WHERE ph.Patient_Record_Rank = 1;
GO


/*====================================================================
  SECTION 7
  CREATE DATASET INDEXES
====================================================================*/

CREATE UNIQUE CLUSTERED INDEX
    IX_CS2_Page1_Dataset_Row_ID
ON dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
(
    Dataset_Row_ID
);
GO

CREATE NONCLUSTERED INDEX
    IX_CS2_Page1_Patient_ID
ON dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
(
    Patient_ID
);
GO


/*====================================================================
  SECTION 8
  DISPLAY THE COMPLETED PAGE 1 DATASET
====================================================================*/

SELECT
    *
FROM dbo.PRHS_CS2_Page1_Clinical_Quality_Performance_Dataset
ORDER BY
    Dataset_Row_ID;
GO