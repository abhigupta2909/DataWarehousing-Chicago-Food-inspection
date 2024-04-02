-- insert to Dim_date
INSERT INTO chicago_ins.Dim_date
SELECT TO_CHAR(datum, 'yyyymmdd')::INT AS date_key,
       datum AS date_actual,
       EXTRACT(EPOCH FROM datum) AS epoch,
       TO_CHAR(datum, 'fmDDth') AS day_suffix,
       TO_CHAR(datum, 'TMDay') AS day_name,
       EXTRACT(ISODOW FROM datum) AS day_of_week,
       EXTRACT(DAY FROM datum) AS day_of_month,
       datum - DATE_TRUNC('quarter', datum)::DATE + 1 AS day_of_quarter,
       EXTRACT(DOY FROM datum) AS day_of_year,
       TO_CHAR(datum, 'W')::INT AS week_of_month,
       EXTRACT(WEEK FROM datum) AS week_of_year,
       EXTRACT(ISOYEAR FROM datum) || TO_CHAR(datum, '"-W"IW-') || EXTRACT(ISODOW FROM datum) AS week_of_year_iso,
       EXTRACT(MONTH FROM datum) AS month_actual,
       TO_CHAR(datum, 'TMMonth') AS month_name,
       TO_CHAR(datum, 'Mon') AS month_name_abbreviated,
       EXTRACT(QUARTER FROM datum) AS quarter_actual,
       CASE
           WHEN EXTRACT(QUARTER FROM datum) = 1 THEN 'First'
           WHEN EXTRACT(QUARTER FROM datum) = 2 THEN 'Second'
           WHEN EXTRACT(QUARTER FROM datum) = 3 THEN 'Third'
           WHEN EXTRACT(QUARTER FROM datum) = 4 THEN 'Fourth'
           END AS quarter_name,
       EXTRACT(YEAR FROM datum) AS year_actual,
       datum + (1 - EXTRACT(ISODOW FROM datum))::INT AS first_day_of_week,
       datum + (7 - EXTRACT(ISODOW FROM datum))::INT AS last_day_of_week,
       datum + (1 - EXTRACT(DAY FROM datum))::INT AS first_day_of_month,
       (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE AS last_day_of_month,
       DATE_TRUNC('quarter', datum)::DATE AS first_day_of_quarter,
       (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE AS last_day_of_quarter,
       TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD') AS first_day_of_year,
       TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') AS last_day_of_year,
       TO_CHAR(datum, 'mmyyyy') AS mmyyyy,
       TO_CHAR(datum, 'mmddyyyy') AS mmddyyyy,
       CASE
           WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN TRUE
           ELSE FALSE
           END AS weekend_indr
FROM (SELECT '2010-01-01'::DATE + SEQUENCE.DAY AS datum
      FROM GENERATE_SERIES(0, 29219) AS SEQUENCE (DAY)
      GROUP BY SEQUENCE.DAY) DQ
ORDER BY 1;

-- insert to Dim_Chicago_Restaurants
INSERT INTO chicago_ins.Dim_Chicago_Restaurants (DBA_Name, AKA_Name)
SELECT DISTINCT DBA_Name, AKA_Name
FROM chicago_ins.STG_CHICAGO_FOOD_ESTD_INS;

-- insert to Dim_Chicago_Geo
INSERT INTO chicago_ins.Dim_Chicago_Geo (Address, City, State, Zip, Latitude, Longitude, Location)
SELECT DISTINCT Address, City, State, Zip, Latitude, Longitude, Location
FROM chicago_ins.STG_CHICAGO_FOOD_ESTD_INS;

select * from chicago_ins.Dim_Chicago_Geo;

-- insert to Dim_Chicago_FacilityType
INSERT INTO chicago_ins.Dim_Chicago_FacilityType (FacilityType)
SELECT DISTINCT Facility_Type
FROM chicago_ins.STG_CHICAGO_FOOD_ESTD_INS;

select * from chicago_ins.Dim_Chicago_FacilityType;

-- inser to Dim_Chicago_FoodInspectionResults
INSERT INTO chicago_ins.Dim_Chicago_FoodInspectionResults (Results)
SELECT DISTINCT Results
FROM chicago_ins.STG_CHICAGO_FOOD_ESTD_INS;

select * from chicago_ins.Dim_Chicago_FoodInspectionResults;

-- insert to Dim_Chicago_FoodInspectionType
INSERT INTO chicago_ins.Dim_Chicago_FoodInspectionType (InspectionType)
SELECT DISTINCT Inspection_Type
FROM chicago_ins.STG_CHICAGO_FOOD_ESTD_INS;

select * from chicago_ins.Dim_Chicago_FoodInspectionType;

--  insert to Dim_Chicago_FoodRiskCategory
INSERT INTO chicago_ins.Dim_Chicago_FoodRiskCategory (Risk)
SELECT DISTINCT Risk FROM chicago_ins.STG_CHICAGO_FOOD_ESTD_INS;

select * from chicago_ins.Dim_Chicago_FoodRiskCategory;


-- Load data into the Dim_Chicago_ViolationCodes table
INSERT INTO chicago_ins.Dim_Chicago_ViolationCodes (ViolationCode, ViolationDescription)
SELECT DISTINCT
    CAST(SUBSTRING(Violations, '^\d+') AS INTEGER) AS ViolationCode,
    CASE 
        WHEN Violations = 'NIL' THEN 'NIL'
        ELSE SUBSTRING(Violations, '\d+\. (.*)$')
    END AS ViolationDescription
FROM
    chicago_ins.STG_CHICAGO_FOOD_ESTD_INS;

UPDATE chicago_ins.Dim_Chicago_ViolationCodes
SET ViolationCode = -1
WHERE ViolationDescription = 'NIL';


-- load Dim_Chicago_BusinessLicenses
INSERT INTO chicago_ins.Dim_Chicago_BusinessLicenses
(ID, LICENSE_ID, ACCOUNT_NUMBER, SITE_NUMBER, LEGAL_NAME, DOING_BUSINESS_AS_NAME, 
 ADDRESS, CITY, STATE, ZIP_CODE, LICENSE_CODE, LICENSE_DESCRIPTION, BUSINESS_ACTIVITY_ID, 
 BUSINESS_ACTIVITY, APPLICATION_TYPE, LICENSE_NUMBER, LICENSE_STATUS)
SELECT
	Id,
	License_Id,
	Account_Number,
	Site_Number,
	Legal_Name,
	Doing_Business_As_Name,
	Address,
	City,
	State,
	ZipCode,
	License_Code,
	License_Description,
	Business_Activity_Id,
	Business_Activity,
	Application_Type,
	License_number,
	License_Status
FROM chicago_ins.STG_BUSS_LIC;


-- handle null license ids'
INSERT INTO chicago_ins.Dim_Chicago_BusinessLicenses (
	ID, LICENSE_ID, ACCOUNT_NUMBER, LEGAL_NAME, SITE_NUMBER,
	DOING_BUSINESS_AS_NAME, ADDRESS, CITY, STATE, ZIP_CODE,
	LICENSE_CODE, LICENSE_DESCRIPTION, BUSINESS_ACTIVITY_ID,
	BUSINESS_ACTIVITY, APPLICATION_TYPE, LICENSE_NUMBER, LICENSE_STATUS
) VALUES (
	'-1', -1, 12345, 'Dummy Company', 1,
	'Dummy Company', '123 Main St', 'Chicago', 'IL', '60601',
	123, 'Dummy License', 'dummy_activity_id',
	'Dummy Activity', 'dummy_application_type', 123456, 'Active'
);



-- Insert to fact table FCT_Chicago_FoodInspections
INSERT INTO chicago_ins.FCT_Chicago_FoodInspections (InspectionID, InspectionDate,Inspection_Date_Key, RestaurantSK, License_Id, GeoSK, FacilitySK, InspectionTypeSK, ResultsSK, RiskSK)
SELECT 
    s.Inspection_ID AS InspectionID,
    s.Inspection_Date AS InspectionDate,
	dcd.date_key AS Inspection_Date_Key,
	dr.RestaurantSK AS RestaurantSK,
	s.License_Id AS License_Id,
	dcg.GeoSK AS GeoSK,
	dcf.FacilitySK AS FacilitySK,
	dct.InspectionTypeSK AS InspectionTypeSK,
	dcr.ResultsSK AS ResultsSK,
	dcrsk.RiskSK AS RiskSK
FROM 
    chicago_ins.STG_CHICAGO_FOOD_ESTD_INS s
	JOIN chicago_ins.Dim_date dcd ON s.Inspection_Date = dcd.date_actual 
	JOIN chicago_ins.Dim_Chicago_Restaurants dr ON s.DBA_Name = dr.DBA_Name and s.AKA_Name=dr.AKA_Name
	JOIN chicago_ins.Dim_Chicago_Geo dcg ON s.Address = dcg.Address AND s.City = dcg.City AND s.State = dcg.State AND s.Zip = dcg.Zip
	JOIN chicago_ins.Dim_Chicago_FacilityType dcf ON s.Facility_Type = dcf.FacilityType
	JOIN chicago_ins.Dim_Chicago_FoodInspectionType dct ON s.Inspection_Type = dct.InspectionType
	JOIN chicago_ins.Dim_Chicago_FoodInspectionResults dcr ON s.Results = dcr.Results
	JOIN chicago_ins.Dim_Chicago_FoodRiskCategory dcrsk ON s.Risk = dcrsk.Risk;



--  load FCT_Chicago_FoodInspections_Violations 
INSERT INTO chicago_ins.FCT_Chicago_FoodInspections_Violations (InspectionID, ViolationSK, ViolationComment)
select sq.Inspection_ID, v.ViolationSK, v.ViolationDescription from (
	SELECT 
		Inspection_ID,
		CASE WHEN Violations = 'NIL' THEN -1 ELSE CAST(SUBSTRING(Violations, '^\d+') AS INTEGER) END AS ViolationCode,
		CASE WHEN Violations = 'NIL' THEN 'NIL' ELSE SUBSTRING(Violations, '\d+\. (.*)$') END AS ViolationDescription
	FROM chicago_ins.STG_CHICAGO_FOOD_ESTD_INS
) sq
JOIN chicago_ins.Dim_Chicago_ViolationCodes v on 
sq.ViolationCode = v.ViolationCode and sq.ViolationDescription = v.ViolationDescription;


