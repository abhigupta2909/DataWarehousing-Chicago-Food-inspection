import psycopg2
import csv
import pandas as pd
hostname = 'localhost'
dbName = 'ChicagoFoodDWH'
username = 'postgres'
password = 263590
port = 5432
conn = None


def deltaLoadFoodInspectionData(n):
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

                cur.execute("""
                    DROP TABLE IF EXISTS chicago_ins.DELTA_CHICAGO_FOOD_ESTD_INS;

                    CREATE TABLE chicago_ins.DELTA_CHICAGO_FOOD_ESTD_INS(
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
                        Location character(40) NULL)"""
                            )
                # get first n rows
                df = pd.read_csv(
                    './data/progressiveFoodInspectionData.csv', nrows=n)

                df.InspectionDate = pd.to_datetime(df.InspectionDate)
                # remaining
                df_remaining = pd.read_csv(
                    './data/progressiveFoodInspectionData.csv', skiprows=range(1, n), header=0)
                # print(df.info())
                for index, row in df.iterrows():
                    print(row)
                    cur.execute(f"INSERT INTO chicago_ins.DELTA_CHICAGO_FOOD_ESTD_INS \
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


deltaLoadFoodInspectionData(5)
