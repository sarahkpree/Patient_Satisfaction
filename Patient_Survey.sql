-- DATA CLEANING

-- Change column data types 

ALTER TABLE Hospital_Beds
ALTER COLUMN Fiscal_Year_Begin_Date DATE;

ALTER TABLE Hospital_Beds
ALTER COLUMN Fiscal_Year_End_Date DATE;

ALTER TABLE Survey_Data
ALTER COLUMN Start_Date DATE;

ALTER TABLE Survey_Data
ALTER COLUMN End_Date DATE;

-- Provider_CNN should be a length of six and no duplicate hospitals [some hospitals have multiple bed counts because their counts were updated]
-- Join the two tables for Tableau prep

ALTER TABLE Hospital_Beds
ALTER COLUMN Provider_CCN VARCHAR(10);

-- The most recent row by End_Date for each Provider_CNN will be designated with a "1". The later dates will get a subsequent number.
-- This allows us to filter the dataset with the most recent bed count for each facility. 

WITH Hospital_Beds_Prep AS 
(SELECT 
    Provider_CCN, Hospital_Name, Fiscal_Year_Begin_Date, Fiscal_Year_End_Date, 
    number_of_beds, ROW_NUMBER() OVER (PARTITION BY Provider_CCN ORDER BY Fiscal_Year_End_Date DESC) AS Nth_Row
FROM Hospital_Beds
)

-- Add a leading zero when the Facility_ID (Provider_CCN) does not contain 6 numbers. Join the two tables together for Tableau prep. 

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

-- Exported query result as Excel file for dashboard. 
