CREATE SCHEMA IF NOT EXISTS chicago_ins;

-- create staging table for food inspection

DROP TABLE IF EXISTS chicago_ins.STG_CHICAGO_FOOD_ESTD_INS;

CREATE TABLE chicago_ins.STG_CHICAGO_FOOD_ESTD_INS(
    Stg_Chicago_Food_Estd_Ins_ID bigserial NOT NULL,
    Inspection_ID int NULL,
    DBA_Name  varchar(255) NULL,
    AKA_Name  varchar(255) NULL,
    License_Id integer NULL,
    Facility_Type  varchar(255) NULL,
    Risk character(255) NULL,
    Address  varchar(255) NULL,
    City  varchar(20) NULL,
    State character(2) NULL,
    Zip integer NULL,
    Inspection_Date Date NULL,
    Inspection_Type  varchar(100) NULL,
    Results  varchar(255) NULL,
    Violations text NULL,
    Latitude character(18) NULL,
    Longitude character(18) NULL,
    Location character(40) NULL,
    CONSTRAINT PK_STG_CHICAGO_FOOD_ESTD_INS PRIMARY KEY (Stg_Chicago_Food_Estd_Ins_ID)
);

CREATE INDEX idx_license_id ON chicago_ins.STG_CHICAGO_FOOD_ESTD_INS (License_Id);


-- staging table for license
DROP TABLE IF EXISTS chicago_ins.STG_BUSS_LIC;

CREATE TABLE chicago_ins.STG_BUSS_LIC(
    Stg_Buss_Lic_ID                          bigserial         NOT NULL,
    Id                                       char(16)          NULL,
    License_Id                               integer           NULL,
    Account_Number                           integer           NULL,
    Site_Number                              smallint          NULL,
    Legal_Name                               varchar(255)      NULL,
    Doing_Business_As_Name                   varchar(255)      NULL,
    Address                                  varchar(255)      NULL,
    City                                     varchar(255)      NULL,
    State                                    varchar(255)       NULL,
    ZipCode                                  varchar(10)       NULL,
    License_Code                             smallint          NULL,
	Application_Type                         varchar(100)      NULL,
    License_Description                      varchar(255)      NULL,
    Business_Activity_Id                     varchar(255)      NULL,
    Business_Activity                        text              NULL,
    License_number                           integer           NULL,
    License_Status                           varchar(10)       NULL,
    CONSTRAINT PK_STG_BUSS_LIC PRIMARY KEY (Stg_Buss_Lic_ID)
);

CREATE INDEX idx_STG_BUSS_LIC_License_Id 
    ON chicago_ins.STG_BUSS_LIC(License_Id);


CREATE INDEX idx_STG_BUSS_LIC_License_Status 
    ON chicago_ins.STG_BUSS_LIC(License_Status);
	
CREATE INDEX idx_STG_BUSS_LIC_Application_Type 
    ON chicago_ins.STG_BUSS_LIC(Application_Type);