CREATE SCHEMA IF NOT EXISTS chicago_ins;


DROP TABLE IF EXISTS chicago_ins.Dim_Chicago_BusinessLicenses CASCADE;

CREATE TABLE chicago_ins.Dim_Chicago_BusinessLicenses (
	ID char(16),
	LICENSE_ID integer PRIMARY KEY,
	ACCOUNT_NUMBER integer,
	LEGAL_NAME varchar(255),
	SITE_NUMBER integer,
	DOING_BUSINESS_AS_NAME varchar(255),
	ADDRESS varchar(255),
	CITY varchar(255),
	STATE varchar(255),
	ZIP_CODE char(10),
	LICENSE_CODE integer,
	LICENSE_DESCRIPTION varchar(255),
	BUSINESS_ACTIVITY_ID varchar(81),
	BUSINESS_ACTIVITY text,
	APPLICATION_TYPE varchar(200),
	LICENSE_NUMBER integer,
	LICENSE_STATUS varchar(10)
);



DROP TABLE IF EXISTS chicago_ins.Dim_Chicago_FacilityType CASCADE;
CREATE TABLE chicago_ins.Dim_Chicago_FacilityType (
    FacilitySK SERIAL PRIMARY KEY NOT NULL,
    FacilityType varchar(47)
);

DROP TABLE IF EXISTS chicago_ins.Dim_Chicago_FoodInspectionResults CASCADE;
CREATE TABLE chicago_ins.Dim_Chicago_FoodInspectionResults (
    ResultsSK SERIAL PRIMARY KEY,
    Results varchar(20)
);


DROP TABLE IF EXISTS chicago_ins.Dim_Chicago_FoodInspectionType CASCADE;

CREATE TABLE chicago_ins.Dim_Chicago_FoodInspectionType (
    InspectionTypeSK SERIAL PRIMARY KEY,
    InspectionType varchar(41)
);

DROP TABLE IF EXISTS chicago_ins.Dim_Chicago_FoodRiskCategory CASCADE;

CREATE TABLE chicago_ins.Dim_Chicago_FoodRiskCategory (
    RiskSK SERIAL PRIMARY KEY,
    Risk varchar(30)
);

DROP TABLE IF EXISTS chicago_ins.Dim_Chicago_Geo CASCADE;

CREATE TABLE chicago_ins.Dim_Chicago_Geo (
    GeoSK SERIAL PRIMARY KEY,
    Address varchar(200),
    City varchar(100),
    State varchar(100),
    Zip int,
    Latitude varchar(18),
    Longitude varchar(18),
    Location varchar(40)
);

DROP TABLE IF EXISTS chicago_ins.Dim_Chicago_Restaurants CASCADE;

CREATE TABLE chicago_ins.Dim_Chicago_Restaurants (
	RestaurantSK  serial PRIMARY KEY,
	DBA_Name varchar(79) NULL,
	AKA_Name varchar(79) NULL
);


DROP TABLE IF EXISTS chicago_ins.Dim_Chicago_ViolationCodes CASCADE;

CREATE TABLE chicago_ins.Dim_Chicago_ViolationCodes (
    ViolationSK SERIAL PRIMARY KEY,
    ViolationCode INTEGER,
    ViolationDescription text,
    Current_flag BOOLEAN
);


DROP TABLE IF EXISTS chicago_ins.FCT_Chicago_FoodInspections CASCADE;

CREATE TABLE chicago_ins.FCT_Chicago_FoodInspections (
    InspectionID int NOT NULL,
    Inspection_Date_Key int NULL,
    InspectionDate date NULL,
    RestaurantSK int NULL,
    License_Id int NULL,
    GeoSK int NULL,
    FacilitySK int NULL,
    InspectionTypeSK int NULL,
    ResultsSK int NULL,
    RiskSK int NULL,
    PRIMARY KEY (InspectionID)
);

DROP TABLE IF EXISTS chicago_ins.FCT_Chicago_FoodInspections_Violations CASCADE;

CREATE TABLE chicago_ins.FCT_Chicago_FoodInspections_Violations (
	InspectionID int NOT NULL,
	ViolationSK int NOT NULL,
	ViolationComment text NULL,
	PRIMARY KEY (InspectionID, ViolationSK)
);

DROP TABLE if exists chicago_ins.Dim_date CASCADE;

CREATE TABLE chicago_ins.Dim_date
(
  date_key                 INT NOT NULL,
  date_actual              DATE NOT NULL,
  epoch                    BIGINT NOT NULL,
  day_suffix               VARCHAR(4) NOT NULL,
  day_name                 VARCHAR(9) NOT NULL,
  day_of_week              INT NOT NULL,
  day_of_month             INT NOT NULL,
  day_of_quarter           INT NOT NULL,
  day_of_year              INT NOT NULL,
  week_of_month            INT NOT NULL,
  week_of_year             INT NOT NULL,
  week_of_year_iso         CHAR(10) NOT NULL,
  month_actual             INT NOT NULL,
  month_name               VARCHAR(9) NOT NULL,
  month_name_abbreviated   CHAR(3) NOT NULL,
  quarter_actual           INT NOT NULL,
  quarter_name             VARCHAR(9) NOT NULL,
  year_actual              INT NOT NULL,
  first_day_of_week        DATE NOT NULL,
  last_day_of_week         DATE NOT NULL,
  first_day_of_month       DATE NOT NULL,
  last_day_of_month        DATE NOT NULL,
  first_day_of_quarter     DATE NOT NULL,
  last_day_of_quarter      DATE NOT NULL,
  first_day_of_year        DATE NOT NULL,
  last_day_of_year         DATE NOT NULL,
  mmyyyy                   CHAR(6) NOT NULL,
  mmddyyyy                 CHAR(10) NOT NULL,
  weekend_indr             BOOLEAN NOT NULL
);

ALTER TABLE chicago_ins.Dim_date ADD CONSTRAINT d_date_date_dim_id_pk PRIMARY KEY (date_key);

CREATE INDEX d_date_date_actual_idx ON chicago_ins.Dim_date(date_actual);

ALTER TABLE chicago_ins.FCT_Chicago_FoodInspections
ADD CONSTRAINT fk_Dim_Chicago_BusinessLicenses_FCT_Chicago_FoodInspections FOREIGN KEY (LICENSE_ID)
REFERENCES chicago_ins.Dim_Chicago_BusinessLicenses (LICENSE_ID);

ALTER TABLE chicago_ins.FCT_Chicago_FoodInspections
ADD CONSTRAINT fk_Dim_InspectionDate_FCT_Chicago_FoodInspections FOREIGN KEY (Inspection_Date_Key)
REFERENCES chicago_ins.Dim_date (date_key);

ALTER TABLE chicago_ins.FCT_Chicago_FoodInspections
ADD CONSTRAINT fk_Dim_Chicago_FacilityType_FCT_Chicago_FoodInspections FOREIGN KEY (FacilitySK)
REFERENCES chicago_ins.Dim_Chicago_FacilityType (FacilitySK);

ALTER TABLE chicago_ins.FCT_Chicago_FoodInspections
ADD CONSTRAINT fk_Dim_Chicago_FoodInspectionResults_FCT_Chicago_FoodInspections FOREIGN KEY (ResultsSK)
REFERENCES chicago_ins.Dim_Chicago_FoodInspectionResults (ResultsSK);

ALTER TABLE chicago_ins.FCT_Chicago_FoodInspections ADD CONSTRAINT fk_Dim_Chicago_FoodInspectionType_FCT_Chicago_FoodInspections FOREIGN KEY (InspectionTypeSK)
REFERENCES chicago_ins.Dim_Chicago_FoodInspectionType (InspectionTypeSK);

ALTER TABLE chicago_ins.FCT_Chicago_FoodInspections ADD CONSTRAINT fk_Dim_Chicago_FoodRiskCategory_FCT_Chicago_FoodInspections FOREIGN KEY (RiskSK)
REFERENCES chicago_ins.Dim_Chicago_FoodRiskCategory (RiskSK);

ALTER TABLE chicago_ins.FCT_Chicago_FoodInspections ADD CONSTRAINT fk_Dim_Chicago_Geo_FCT_Chicago_FoodInspections FOREIGN KEY (GeoSK)
REFERENCES chicago_ins.Dim_Chicago_Geo (GeoSK);

ALTER TABLE chicago_ins.FCT_Chicago_FoodInspections
ADD CONSTRAINT fk_Dim_Chicago_Restaurants_FCT_Chicago_FoodInspections FOREIGN KEY (RestaurantSK)
REFERENCES chicago_ins.Dim_Chicago_Restaurants (RestaurantSK);

ALTER TABLE chicago_ins.FCT_Chicago_FoodInspections_Violations
ADD CONSTRAINT fk_Dim_Chicago_ViolationCodes_FCT_Chicago_FoodInspections_Violations FOREIGN KEY (ViolationSK)
REFERENCES chicago_ins.Dim_Chicago_ViolationCodes (ViolationSK);

