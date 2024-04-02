import psycopg2
import csv
import pandas as pd
hostname = 'localhost'
dbName = 'ChicagoFoodDWH'
username = 'postgres'
password = 263590
port = 5432
conn = None


def stageFoodInspectionData():
    #  ddl
    try:
        with psycopg2.connect(
                host=hostname,
                dbname=dbName,
                user=username,
                password=password,
                port=port) as conn:

            with conn.cursor() as cur:
                print('Connection success!!!')
                df = pd.read_csv(
                    './data/stageFoodInspectionDataFinal.csv', low_memory=False)
                # print('###### ', len(df))
                df.InspectionDate = pd.to_datetime(df.InspectionDate)
                # print(df.info())
                for index, row in df.iterrows():
                    # print(row)
                    cur.execute(f"INSERT INTO chicago_ins.STG_CHICAGO_FOOD_ESTD_INS \
                                (Inspection_ID,DBA_Name,AKA_Name,License_Id,Facility_Type,Risk,Address,City,State,Zip,Inspection_Date,Inspection_Type,Results,Violations,Latitude,Longitude,Location) \
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                                (row['InspectionID'], row['DBA_Name'], row['AKA_Name'],
                                 row['LicenseId'], row['FacilityType'], row['Risk'], row['Address'],
                                 row['City'], row['State'], row['Zip'], row['InspectionDate'],
                                 row['InspectionType'], row['Results'],
                                 row['Violations'], row['Latitude'],
                                 row['Longitude'], row['Location'],
                                 ))

            # Commit the changes to the database
            conn.commit()

    except Exception as err:
        print(err)
    finally:
        if conn is not None:
            conn.close()


def stageFoodBusinessData():
    #  ddl
    try:
        with psycopg2.connect(
                host=hostname,
                dbname=dbName,
                user=username,
                password=password,
                port=port) as conn:

            with conn.cursor() as cur:
                print('Connection pass!!!')
                df = pd.read_csv(
                    './data/stageBusiness_Licenses.csv', low_memory=False)
                for index, row in df.iterrows():
                    # print(row)
                    cur.execute(f"INSERT INTO chicago_ins.STG_BUSS_LIC \
                        (id, license_id, account_number, site_number, legal_name, doing_business_as_name, address, city, \
                        state, zipcode,license_code, license_description,\
                        business_activity_id, business_activity, license_number, application_type, license_status) \
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                                (row['ID'], row['LICENSE ID'], row['ACCOUNT NUMBER'], row['SITE NUMBER'],
                                 row['LEGAL NAME'], row['DOING BUSINESS AS NAME'],
                                 row['ADDRESS'], row['CITY'], row['STATE'], row['ZIP CODE'],
                                 row['LICENSE CODE'], row['LICENSE DESCRIPTION'], row['BUSINESS ACTIVITY ID'],
                                 row['BUSINESS ACTIVITY'], row['LICENSE NUMBER'],
                                 row['APPLICATION TYPE'], row['LICENSE STATUS']))
            # Commit the changes to the database
            conn.commit()

    except Exception as err:
        print(err)
    finally:
        if conn is not None:
            conn.close()


stageFoodInspectionData()

stageFoodBusinessData()
