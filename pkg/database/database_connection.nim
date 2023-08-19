import db_connector/db_postgres


proc addMessage*(conn: Dbconn, text: string) =
  let sqlQuery = sql"INSERT INTO messages(text) VALUES(?)"  # It takes a parameter against the query, that's why Dbconn parameter is ignored. It's not a part of it.
  conn.exec(sqlQuery, text)


proc getMessages*(conn: Dbconn) =
  let rows = conn.getAllRows(sql"SELECT text FROM messages")
  for row in rows:
    echo row

proc testConnection*(conn: Dbconn): bool =
  try:
    let queryResult = conn.getAllRows(sql"SELECT 1")  # Adjust this line based on the actual method for executing queries
    if queryResult.len > 0 and queryResult[0][0] == "1":
      return true
  except Exception:
    echo "An error occurred while testing the connection: ", getCurrentExceptionMsg()
  return false
