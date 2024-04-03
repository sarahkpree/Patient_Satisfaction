# Patient Reported Satisfaction Analysis (HCAHPS)

## Table of Contents

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning and Preparation](#data-cleaning-and-preparation)
- [Data Visualization](#data-visualization)
- [Limitations](#limitations)

### Project Overview
The Hospital Consumer Assessment of Healthcare Providers and Systems (HCAHPS) survey is a standardized survey used to measure patients' perspectives on the quality of care they received in the hospital. The survey encompasses various aspects of the patient experience, including communication with nurses and doctors, cleanliness and quietness of the hospital environment, pain management, discharge information, and overall rating of the hospital. The goal of this project was to create a Tableau dashboard that compares patient safisfaction across hospitals in the United States to examine healthcare quality, identify areas for improvement, and improve transparency.

### Data Sources
The primary dataset used for this analysis is the "HCAHPS.csv" file, containing detailed information about the patient survey responses across hospitals in the United States. In addition, there is a "Hospital_Beds.csv" file which lists the number of beds each hospital has available. 

### Tools

- Microsoft SQL Server - Data Inspection and Cleaning
- Tableau - Data Visualization

### Data Cleaning and Preparation

In the initial data preparation phase, we performed the following tasks:
- Data loading and inspection
- Identification of null values.
- Data formatting (alter data type where appropriate, ensure uniformity of data in each column, delete duplicate records, etc.)

```sql
-- Provider_CNN should be a length of six and no duplicate hospitals [some hospitals have multiple bed counts because their counts were updated]
-- Join the two tables for Tableau prep

WITH Hospital_Beds_Prep AS 
(SELECT 
    Provider_CCN, Hospital_Name, Fiscal_Year_Begin_Date, Fiscal_Year_End_Date, 
    number_of_beds, ROW_NUMBER() OVER (PARTITION BY Provider_CCN ORDER BY Fiscal_Year_End_Date DESC) AS Nth_Row
FROM Hospital_Beds
)

-- Add a leading zero when the Facility_ID (Provider_CCN) does not contain 6 numbers. All IDs should be uniform and contain 6 digits.

SELECT CASE 
        WHEN LEN(Facility_ID) < 6 THEN 
            CONCAT(
                SUBSTRING('000000', 1, 6 - LEN(Facility_ID)),
                Facility_ID
            )
        ELSE Facility_ID
    END AS Facility_ID, Facility_Name, Address, City_Town, State, ZIP_Code, County_Parish, 
    Telephone_Number, HCAHPS_Measure_ID, HCAHPS_Question, HCAHPS_Answer_Description, HCAHPS_Answer_Percent, Number_of_Completed_Surveys,
    Survey_Response_Rate_Percent, Start_Date, End_Date, Hospital_Beds_Prep.number_of_beds, Hospital_Beds_Prep.Fiscal_Year_Begin_Date, Hospital_Beds_Prep.Fiscal_Year_End_Date
FROM Survey_Data
LEFT JOIN Hospital_Beds_Prep ON Survey_Data.Facility_ID = Hospital_Beds_Prep.Provider_CCN
AND Hospital_Beds_Prep.Nth_Row = 1;
```

### Data Visualization
The Tableau dashboard provides a detailed snapshot of patient satisfaction across US hospitals, offering valuable insights for healthcare professionals. Users can filter by state and hospital size to tailor their analysis. Visualizations include the percentage of patients rating hospitals 9 or 10, survey completion rates, and comparisons of hospitals' performance relative to other hospitals in their cohort (based on state and hospital bed capacity). This user-friendly dashboard empowers healthcare providers to identify areas for improvement and enhance patient care.

### Limitations
- The completeness of the patient satisfaction data may vary across hospitals, possibly leading to inconsistencies in the analysis.
- The number of completed surveys received by each hospital may not accurately reflect the patient population's diversity and experiences. Hospitals with low survey completion rates may not provide a complete picture, which could lead to skewed results.
- Grouping hospitals by state and size for comparison purposes may overlook other relevant factors that influence patient satisfaction.

