/*====================================================================
  PALMETTO REGIONAL HEALTH SYSTEM

  CASE STUDY 2:
  CLINICAL QUALITY & PERFORMANCE IMPROVEMENT

  DASHBOARD PAGE 2:
  PATIENT RISK & POPULATION INSIGHTS

  FILE:
  06_CS2_Patient_Risk_Population_Dataset.sql

  PURPOSE:
  Generate the final dataset used for the Power BI dashboard and
  export the results as a CSV file for GitHub.

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
  EXPORT THE FINAL DATASET

  This query returns the complete patient-level dataset used for
  Dashboard Page 2.

  Export the results from SSMS using:
      Save Results As...
  and save the file as:

      06_CS2_Patient_Risk_Population_Dataset.csv
====================================================================*/

SELECT
    *
FROM dbo.PRHS_CS2_Page2_Patient_Risk_Population_Dataset
ORDER BY
    Dataset_Row_ID;
GO