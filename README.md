# Patient Reported Satisfaction Analysis (HCAHPS)

## Table of Contents

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning and Preparation](#data-cleaning-and-preparation)
- [Results](#results)
- [Recommendations](#recommendations)
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



### Results

The analysis results are summarized as follows:
1. **Identifying Healthiest Employees:** There are 111 employees meeting specific health criteria, including being non-smokers, non-drinkers, having a BMI less than 25, and exhibiting lower absenteeism than the average. These employees are entitled to a bonus from a $100,000 allocation, with each eligible employee set to receive approximately $900 as recognition for their healthy lifestyle choices and low absenteeism.

2.  **Non-Smoker Identification:** There are 686 non-smoking employees. With a budget allocation of $983,221 from the HR department, an hourly increase rate of $0.68 was determined for these employees, aiming to incentivize a smoke-free workplace environment.
   
3. **Reasons for Absenteeism:** The top 3 reasons for employee absenteeism are medical consultation, dental consultation, and physiotherapy.
   
4. **Temporal Analysis of Absenteeism:** Examination of absenteeism patterns throughout the week revealed Monday as the predominant day for employee absences, however with marginal differences observed across the remaining week days. Additionally, our analysis identified March as the month with the most absences.

5. **Education Level and Absenteeism:** The analysis revealed that employees with higher education levels tend to exhibit lower average absenteeism hours. However, the difference in absenteeism rates among the different education levels is minimal.

6. **Impact of Commute Distance:** There does not appear to be a relationship between commute distance and absenteeism.

7. **Tenure and Absenteeism:** The length of employment does not appear to impact absenteeism.

8. **Effect of Social Habits:** Absenteeism rates between social drinkers/smokers and non-drinkers/non-smokers do not appear to be significantl.

9. **Correlation between Age and Absenteeism:** Middle-aged employees, particularly those in their 50s, exhibit notably higher average absenteeism compared to their younger counterparts. However, it is probable that there are additional underlying factors influencing these absenteeism rates.
   
### Recommendations

Based on the analysis, the following steps are recommended:

1. **Promote Health and Wellness Programs:**
   Given the benefits associated with healthy lifestyle choices, such as lower absenteeism rates and improved employee well-being, consider implementing and promoting health and wellness programs within the organization. 

2. **Flexible Work Arrangements:**
   Recognizing Monday as the most common day for employee absences, consider implementing flexible work arrangements, such as telecommuting, to accommodate employees.

3. **Employee Engagement Initiatives:** Boost employee engagement by implementing recognition programs, offering career development opportunities, and promoting work-life balance initiatives. These efforts can uplift morale and decrease absenteeism among employees.

### Limitations
- Although correlations between variables have been noted, determining causal relationships necessitates additional investigation.
- The analysis findings may not be universally applicable across all organizations or contexts.
- The analysis is based on certain assumptions and interpretations of the data. For instance, the definition of "healthiest employees" may vary among organizations, and the interpretation of absenteeism patterns may be subjective.
