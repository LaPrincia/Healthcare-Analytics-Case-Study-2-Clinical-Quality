/*====================================================================
  PALMETTO REGIONAL HEALTH SYSTEM

  CASE STUDY 2:
  CLINICAL QUALITY & PERFORMANCE IMPROVEMENT

  DASHBOARD PAGE 2:
  PATIENT RISK & POPULATION INSIGHTS

  FILE:
  04_CS2_Patient_Risk_Population_Query.sql

  PLATFORM:
  Microsoft Power BI

  PURPOSE:
  Create an analysis-ready patient-level dataset for evaluating:

      - Patient risk stratification
      - Chronic disease burden
      - Preventive-care opportunities
      - Care gaps
      - 30-day readmissions
      - Lifestyle and clinical risk factors
      - Patient intervention priorities

  SOURCE TABLE:
      dbo.Population_Health

  FINAL DATASET:
      dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset

  DATA GRAIN:
  One row per patient

  DATA QUALITY RULE:
  Duplicate Patient_ID records are removed before the final dataset
  is created.
====================================================================*/


/*====================================================================
  SECTION 1
  SELECT THE PROJECT DATABASE
====================================================================*/

USE PalmettoRegionalHealthSystemDW;
GO


/*====================================================================
  SECTION 2
  REMOVE THE PREVIOUS PAGE 2 DATASET

  This allows the query to be rerun without receiving an error that
  the destination table already exists.
====================================================================*/

DROP TABLE IF EXISTS
    dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset;
GO


/*====================================================================
  SECTION 3
  DEDUPLICATE THE POPULATION HEALTH SOURCE

  ROW_NUMBER assigns a sequence to records sharing the same Patient_ID.

  Only Patient_Record_Rank = 1 will be included in the final dataset,
  ensuring one patient-level record per Patient_ID.
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
  CREATE THE PATIENT RISK & POPULATION INSIGHTS DATASET
====================================================================*/

SELECT

    /*================================================================
      DATASET IDENTIFICATION
    ================================================================*/

    ROW_NUMBER() OVER
    (
        ORDER BY ph.Patient_ID
    ) AS Dataset_Row_ID,


    /*================================================================
      PATIENT IDENTIFICATION

      Patient_ID is converted to VARCHAR(20) so it can be used for
      filtering, relationships, and indexing.
    ================================================================*/

    CAST(ph.Patient_ID AS VARCHAR(20)) AS Patient_ID,


    /*================================================================
      PATIENT DEMOGRAPHICS
    ================================================================*/

    ph.Age,

    ph.Gender,

    CASE
        WHEN ph.Age IS NULL
            THEN 'Unknown'

        WHEN ph.Age < 18
            THEN 'Under 18'

        WHEN ph.Age BETWEEN 18 AND 34
            THEN '18-34'

        WHEN ph.Age BETWEEN 35 AND 49
            THEN '35-49'

        WHEN ph.Age BETWEEN 50 AND 64
            THEN '50-64'

        WHEN ph.Age BETWEEN 65 AND 74
            THEN '65-74'

        WHEN ph.Age >= 75
            THEN '75+'

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
      PATIENT RISK STRATIFICATION
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
        WHEN ph.Risk_Level IN ('High', 'Very High')
            THEN 1
        ELSE 0
    END AS High_Risk_Flag,

    CASE
        WHEN ph.Risk_Level = 'Very High'
            THEN 1
        ELSE 0
    END AS Very_High_Risk_Flag,


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

      This calculation counts the number of documented chronic
      conditions for each patient.
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


    /*================================================================
      CHRONIC CONDITION GROUP
    ================================================================*/

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
        ) >= 2
            THEN 1
        ELSE 0
    END AS Multiple_Chronic_Conditions_Flag,


    /*================================================================
      BMI AND CLINICAL RISK
    ================================================================*/

    CAST(ph.BMI AS DECIMAL(10,2)) AS BMI,

    CASE
        WHEN ph.BMI IS NULL
            THEN 'Unknown'

        WHEN ph.BMI < 18.5
            THEN 'Underweight'

        WHEN ph.BMI >= 18.5
             AND ph.BMI < 25
            THEN 'Healthy Weight'

        WHEN ph.BMI >= 25
             AND ph.BMI < 30
            THEN 'Overweight'

        WHEN ph.BMI >= 30
            THEN 'Obese'

        ELSE 'Unknown'
    END AS BMI_Category,

    CASE
        WHEN ph.BMI IS NULL THEN 0
        WHEN ph.BMI < 18.5 THEN 1
        WHEN ph.BMI >= 18.5 AND ph.BMI < 25 THEN 2
        WHEN ph.BMI >= 25 AND ph.BMI < 30 THEN 3
        WHEN ph.BMI >= 30 THEN 4
        ELSE 0
    END AS BMI_Category_Sort,

    CASE
        WHEN ph.BMI >= 30
            THEN 1
        ELSE 0
    END AS Obesity_Flag,


    /*================================================================
      LIFESTYLE RISK
    ================================================================*/

    ph.Smoker,

    CASE
        WHEN ph.Smoker = 'Yes'
            THEN 1
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


    /*================================================================
      PREVENTIVE SCREENING FLAGS
    ================================================================*/

    CASE
        WHEN ph.Preventive_Screening = 'Complete'
            THEN 1
        ELSE 0
    END AS Preventive_Screening_Complete_Flag,

    CASE
        WHEN ph.Preventive_Screening = 'Overdue'
            THEN 1
        ELSE 0
    END AS Preventive_Screening_Overdue_Flag,


    /*================================================================
      FLU VACCINE FLAGS
    ================================================================*/

    CASE
        WHEN ph.Flu_Vaccine = 'Yes'
            THEN 1
        ELSE 0
    END AS Flu_Vaccine_Compliant_Flag,

    CASE
        WHEN ph.Flu_Vaccine = 'No'
            THEN 1
        ELSE 0
    END AS Flu_Vaccine_Noncompliant_Flag,


    /*================================================================
      COLONOSCOPY FLAGS
    ================================================================*/

    CASE
        WHEN ph.Colonoscopy = 'Complete'
            THEN 1
        ELSE 0
    END AS Colonoscopy_Complete_Flag,

    CASE
        WHEN ph.Colonoscopy = 'Overdue'
            THEN 1
        ELSE 0
    END AS Colonoscopy_Overdue_Flag,


    /*================================================================
      MAMMOGRAM FLAGS
    ================================================================*/

    CASE
        WHEN ph.Mammogram = 'Complete'
            THEN 1
        ELSE 0
    END AS Mammogram_Complete_Flag,

    CASE
        WHEN ph.Mammogram = 'Overdue'
            THEN 1
        ELSE 0
    END AS Mammogram_Overdue_Flag,


    /*================================================================
      A1C CONTROL FLAGS
    ================================================================*/

    CASE
        WHEN ph.A1C_Control = 'Controlled'
            THEN 1
        ELSE 0
    END AS A1C_Controlled_Flag,

    CASE
        WHEN ph.A1C_Control = 'Uncontrolled'
            THEN 1
        ELSE 0
    END AS A1C_Uncontrolled_Flag,


    /*================================================================
      PREVENTIVE CARE OPPORTUNITY COUNT

      This field counts documented preventive and chronic-care
      opportunities for each patient.
    ================================================================*/

    (
        CASE
            WHEN ph.Preventive_Screening = 'Overdue' THEN 1
            ELSE 0
        END
        +
        CASE
            WHEN ph.Flu_Vaccine = 'No' THEN 1
            ELSE 0
        END
        +
        CASE
            WHEN ph.Colonoscopy = 'Overdue' THEN 1
            ELSE 0
        END
        +
        CASE
            WHEN ph.Mammogram = 'Overdue' THEN 1
            ELSE 0
        END
        +
        CASE
            WHEN ph.A1C_Control = 'Uncontrolled' THEN 1
            ELSE 0
        END
    ) AS Preventive_Care_Opportunity_Count,


    /*================================================================
      PREVENTIVE CARE OPPORTUNITY GROUP
    ================================================================*/

    CASE
        WHEN
        (
            CASE
                WHEN ph.Preventive_Screening = 'Overdue' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.Flu_Vaccine = 'No' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.Colonoscopy = 'Overdue' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.Mammogram = 'Overdue' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.A1C_Control = 'Uncontrolled' THEN 1
                ELSE 0
            END
        ) = 0
            THEN 'No Documented Opportunities'

        WHEN
        (
            CASE
                WHEN ph.Preventive_Screening = 'Overdue' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.Flu_Vaccine = 'No' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.Colonoscopy = 'Overdue' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.Mammogram = 'Overdue' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.A1C_Control = 'Uncontrolled' THEN 1
                ELSE 0
            END
        ) = 1
            THEN 'One Opportunity'

        ELSE 'Multiple Opportunities'
    END AS Preventive_Care_Opportunity_Group,

    CASE
        WHEN
        (
            CASE
                WHEN ph.Preventive_Screening = 'Overdue' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.Flu_Vaccine = 'No' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.Colonoscopy = 'Overdue' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.Mammogram = 'Overdue' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.A1C_Control = 'Uncontrolled' THEN 1
                ELSE 0
            END
        ) = 0
            THEN 1

        WHEN
        (
            CASE
                WHEN ph.Preventive_Screening = 'Overdue' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.Flu_Vaccine = 'No' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.Colonoscopy = 'Overdue' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.Mammogram = 'Overdue' THEN 1
                ELSE 0
            END
            +
            CASE
                WHEN ph.A1C_Control = 'Uncontrolled' THEN 1
                ELSE 0
            END
        ) = 1
            THEN 2

        ELSE 3
    END AS Preventive_Care_Opportunity_Group_Sort,


    /*================================================================
      PATIENT OUTCOMES AND CARE GAPS
    ================================================================*/

    ph.Readmission_30_Days,

    CASE
        WHEN ph.Readmission_30_Days = 'Yes'
            THEN 1
        ELSE 0
    END AS Readmission_30_Day_Flag,

    ph.Care_Gap,

    CASE
        WHEN ph.Care_Gap = 'Yes'
            THEN 1
        ELSE 0
    END AS Care_Gap_Flag,

    CASE
        WHEN ph.Care_Gap = 'No'
            THEN 1
        ELSE 0
    END AS No_Care_Gap_Flag,


    /*================================================================
      COMBINED POPULATION RISK SCORE

      This portfolio-level score summarizes major documented risk
      indicators. It is intended to support prioritization and does
      not represent a validated clinical prediction model.
    ================================================================*/

    (
        CASE
            WHEN ph.Risk_Level = 'Very High' THEN 4
            WHEN ph.Risk_Level = 'High' THEN 3
            WHEN ph.Risk_Level = 'Medium' THEN 2
            WHEN ph.Risk_Level = 'Low' THEN 1
            ELSE 0
        END
        +
        CASE WHEN ph.Diabetes = 'Yes' THEN 1 ELSE 0 END
        +
        CASE WHEN ph.Hypertension = 'Yes' THEN 1 ELSE 0 END
        +
        CASE WHEN ph.CHF = 'Yes' THEN 1 ELSE 0 END
        +
        CASE WHEN ph.COPD = 'Yes' THEN 1 ELSE 0 END
        +
        CASE WHEN ph.BMI >= 30 THEN 1 ELSE 0 END
        +
        CASE WHEN ph.Smoker = 'Yes' THEN 1 ELSE 0 END
        +
        CASE WHEN ph.Readmission_30_Days = 'Yes' THEN 2 ELSE 0 END
        +
        CASE WHEN ph.Care_Gap = 'Yes' THEN 2 ELSE 0 END
    ) AS Population_Risk_Score,


    /*================================================================
      PATIENT INTERVENTION PRIORITY

      This category helps clinical and population health teams identify
      patients who may require outreach or additional intervention.
    ================================================================*/

    CASE
        WHEN ph.Risk_Level = 'Very High'
             AND ph.Care_Gap = 'Yes'
             AND ph.Readmission_30_Days = 'Yes'
            THEN 'Critical Priority'

        WHEN ph.Risk_Level IN ('High', 'Very High')
             AND ph.Care_Gap = 'Yes'
            THEN 'High Priority'

        WHEN ph.Care_Gap = 'Yes'
             OR ph.Readmission_30_Days = 'Yes'
            THEN 'Moderate Priority'

        ELSE 'Routine Monitoring'
    END AS Intervention_Priority,

    CASE
        WHEN ph.Risk_Level = 'Very High'
             AND ph.Care_Gap = 'Yes'
             AND ph.Readmission_30_Days = 'Yes'
            THEN 1

        WHEN ph.Risk_Level IN ('High', 'Very High')
             AND ph.Care_Gap = 'Yes'
            THEN 2

        WHEN ph.Care_Gap = 'Yes'
             OR ph.Readmission_30_Days = 'Yes'
            THEN 3

        ELSE 4
    END AS Intervention_Priority_Sort,


    /*================================================================
      RECOMMENDED OUTREACH ACTION
    ================================================================*/

    CASE
        WHEN ph.Risk_Level = 'Very High'
             AND ph.Care_Gap = 'Yes'
             AND ph.Readmission_30_Days = 'Yes'
            THEN 'Immediate Clinical Review'

        WHEN ph.Risk_Level IN ('High', 'Very High')
             AND ph.Care_Gap = 'Yes'
            THEN 'Priority Care-Gap Outreach'

        WHEN ph.Readmission_30_Days = 'Yes'
            THEN 'Post-Discharge Follow-Up'

        WHEN ph.Care_Gap = 'Yes'
            THEN 'Preventive Care Outreach'

        ELSE 'Continue Routine Monitoring'
    END AS Recommended_Outreach_Action


/*====================================================================
  SECTION 5
  CREATE THE FINAL PAGE 2 TABLE
====================================================================*/

INTO dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset


/*====================================================================
  SECTION 6
  FILTER TO ONE RECORD PER PATIENT
====================================================================*/

FROM PopulationHealth_Deduplicated AS ph

WHERE ph.Patient_Record_Rank = 1;
GO


/*====================================================================
  SECTION 7
  CREATE DATASET INDEXES

  The clustered index supports the unique dataset-row identifier.

  Because Page 2 contains one row per patient, Patient_ID can also
  receive a unique index.
====================================================================*/

CREATE UNIQUE CLUSTERED INDEX
    IX_CS2_Page2_Dataset_Row_ID
ON dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
(
    Dataset_Row_ID
);
GO

CREATE UNIQUE NONCLUSTERED INDEX
    IX_CS2_Page2_Patient_ID
ON dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
(
    Patient_ID
);
GO


/*====================================================================
  SECTION 8
  DISPLAY THE COMPLETED PAGE 2 DATASET

  The separate Page 2 validation script will be created next.
====================================================================*/

SELECT
    *
FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
ORDER BY
    Dataset_Row_ID;
GO