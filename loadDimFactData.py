import psycopg2

hostname = 'localhost'
dbName = 'ChicagoFoodDWH'
username = 'postgres'
password = 263590
port = 5432
conn = None

#  ddl
# try:
#     with psycopg2.connect(
#             host=hostname,
#             dbname=dbName,
#             user=username,
#             password=password,
#             port=port) as conn:

#         with conn.cursor() as cur:
#             print('Connection pass!!!')
#             cur.execute(open("./loadDimFact.sql", "r").read())


# except Exception as err:
#     print(err)
# finally:
#     if conn is not None:
#         conn.close()


try:
    with psycopg2.connect(
            host=hostname,
            dbname=dbName,
            user=username,
            password=password,
            port=port) as conn:

        with conn.cursor() as cur:
            print('Connection pass!!!')
            cur.execute(
                "SELECT License_Id FROM chicago_ins.STG_CHICAGO_FOOD_ESTD_INS")
            # Fetch all the rows using a for loop
            rows = cur.fetchall()
            for row in rows:
                License_Id = row[0]
                print(License_Id)
                try:
                    cur.execute(
                        f"INSERT INTO chicago_ins.FCT_Chicago_FoodInspections(License_Id) VALUES({License_Id});")
                except:
                    print('except')
                    cur.execute(
                        f"INSERT INTO chicago_ins.FCT_Chicago_FoodInspections(License_Id) VALUES(-1);")


except Exception as err:
    print(err)
finally:
    if conn is not None:
        conn.close()
