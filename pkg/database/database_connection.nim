import db_connector/db_postgres, strutils


proc addQuestion*(conn: Dbconn, message: string): int =
  let sqlQuery = sql"INSERT INTO flashcards(chat_id, question, category) VALUES(?, ?, 'hard') RETURNING id"
  for row in conn.rows(sqlQuery, message):
    let id = row[0].parseInt
    echo "This is a question id: " & $id
    return id

proc addAnswer*(conn: Dbconn, message: string, questionId: int) =
  let sqlQuery = sql"UPDATE flashcards SET answer = ? WHERE id = ?"
  conn.exec(sqlQuery, message, $questionId)

proc showFlashcards*(conn: Dbconn) =
  let rows = conn.getAllRows(sql"SELECT question, answer FROM flashcards")
  for row in rows:
    echo row

proc getMessages*(conn: Dbconn) =
  let rows = conn.getAllRows(sql"SELECT question, category FROM flashcards")
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



