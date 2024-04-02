-- Insert new FacilityType values into Dim_Chicago_FacilityType SCD1
INSERT INTO chicago_ins.Dim_Chicago_FacilityType (FacilityType)
SELECT DISTINCT Facility_Type
FROM chicago_ins.DELTA_CHICAGO_FOOD_ESTD_INS
WHERE Facility_Type IS NOT NULL
AND Facility_Type NOT IN (SELECT FacilityType FROM chicago_ins.Dim_Chicago_FacilityType);


-- Insert to Results to Dim_Chicago_FoodInspectionResults dim :SCD1
INSERT INTO chicago_ins.Dim_Chicago_FoodInspectionResults (Results)
SELECT DISTINCT Results
FROM chicago_ins.DELTA_CHICAGO_FOOD_ESTD_INS
WHERE Results IS NOT NULL
AND Results NOT IN (SELECT Results FROM chicago_ins.Dim_Chicago_FoodInspectionResults);

-- Insert delta to Dim_Chicago_FoodInspectionType: SCD1
INSERT INTO chicago_ins.Dim_Chicago_FoodInspectionType (InspectionType)
SELECT DISTINCT Inspection_Type
FROM chicago_ins.DELTA_CHICAGO_FOOD_ESTD_INS
WHERE Inspection_Type IS NOT NULL
AND Inspection_Type NOT IN (SELECT InspectionType FROM chicago_ins.Dim_Chicago_FoodInspectionType);

-- Insert to Dim_Chicago_FoodRiskCategory : SCD1
INSERT INTO chicago_ins.Dim_Chicago_FoodRiskCategory (Risk)
SELECT DISTINCT Risk
FROM chicago_ins.DELTA_CHICAGO_FOOD_ESTD_INS
WHERE Risk IS NOT NULL
AND Risk NOT IN (SELECT Risk FROM chicago_ins.Dim_Chicago_FoodInspectionType);

-- Insert to Dim_Chicago_Geo upadte is values not present SCD1 
INSERT INTO chicago_ins.Dim_Chicago_Geo (Address, City, State, Zip, Latitude, Longitude, Location)
SELECT DISTINCT Address, City, State, Zip, Latitude, Longitude, Location
FROM chicago_ins.DELTA_CHICAGO_FOOD_ESTD_INS
EXCEPT
SELECT Address, City, State, Zip, Latitude, Longitude, Location
FROM chicago_ins.Dim_Chicago_Geo;

-- insert Dim_Chicago_Restaurants SCD1
INSERT INTO chicago_ins.Dim_Chicago_Restaurants (DBA_Name, AKA_Name)
SELECT DISTINCT DBA_Name, AKA_Name
FROM chicago_ins.DELTA_CHICAGO_FOOD_ESTD_INS
EXCEPT
SELECT DBA_Name, AKA_Name
FROM chicago_ins.Dim_Chicago_Restaurants;


-- insert deltas to Dim_Chicago_ViolationCodes: SCD1

INSERT INTO chicago_ins.Dim_Chicago_ViolationCodes (ViolationCode, ViolationDescription)
SELECT DISTINCT
    CAST(SUBSTRING(Violations, '^\d+') AS INTEGER) AS ViolationCode,
    CASE 
        WHEN Violations = 'NIL' THEN 'NIL'
        ELSE SUBSTRING(Violations, '\d+\. (.*)$')
    END AS ViolationDescription
FROM
    chicago_ins.DELTA_CHICAGO_FOOD_ESTD_INS where Violations != 'NIL';

-- insert to fact table
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
    chicago_ins.DELTA_CHICAGO_FOOD_ESTD_INS s
	JOIN chicago_ins.Dim_date dcd ON s.Inspection_Date = dcd.date_actual 
	JOIN chicago_ins.Dim_Chicago_Restaurants dr ON s.DBA_Name = dr.DBA_Name and s.AKA_Name=dr.AKA_Name
	JOIN chicago_ins.Dim_Chicago_Geo dcg ON s.Address = dcg.Address AND s.City = dcg.City AND s.State = dcg.State AND s.Zip = dcg.Zip
	JOIN chicago_ins.Dim_Chicago_FacilityType dcf ON s.Facility_Type = dcf.FacilityType
	JOIN chicago_ins.Dim_Chicago_FoodInspectionType dct ON s.Inspection_Type = dct.InspectionType
	JOIN chicago_ins.Dim_Chicago_FoodInspectionResults dcr ON s.Results = dcr.Results
	JOIN chicago_ins.Dim_Chicago_FoodRiskCategory dcrsk ON s.Risk = dcrsk.Risk;


-- insert to FCT_Chicago_FoodInspections_Violations
INSERT INTO chicago_ins.FCT_Chicago_FoodInspections_Violations (InspectionID, ViolationSK, ViolationComment)
select sq.Inspection_ID, v.ViolationSK, v.ViolationDescription from (
	SELECT 
		Inspection_ID,
		CASE WHEN Violations = 'NIL' THEN -1 ELSE CAST(SUBSTRING(Violations, '^\d+') AS INTEGER) END AS ViolationCode,
		CASE WHEN Violations = 'NIL' THEN 'NIL' ELSE SUBSTRING(Violations, '\d+\. (.*)$') END AS ViolationDescription
	FROM chicago_ins.DELTA_CHICAGO_FOOD_ESTD_INS
) sq
JOIN chicago_ins.Dim_Chicago_ViolationCodes v on 
sq.ViolationCode = v.ViolationCode and sq.ViolationDescription = v.ViolationDescription;