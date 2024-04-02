import psycopg2

hostname = 'localhost'
dbName = 'ChicagoFoodDWH'
username = 'postgres'
password = 263590
port = 5432
conn = None

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
            cur.execute("DROP SCHEMA chicago_ins CASCADE;")
            cur.execute(open("./stage_ddl.sql", "r").read())
            cur.execute(open("./dim_ddl.sql", "r").read())


except Exception as err:
    print(err)
finally:
    if conn is not None:
        conn.close()
