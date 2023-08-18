import db_connector/db_postgres, ../../src/config

let conn = open(dbHost, dbName, dbUser, dbPassword)
conn.close()
