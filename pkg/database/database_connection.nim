import db_connector/db_postgres, strutils, ../../pkg/message/reply, os


proc addQuestion*(conn: Dbconn, message: string): int =
  let sqlQuery = sql"INSERT INTO flashcards(question, category) VALUES(?, 'hard') RETURNING id"
  for row in conn.rows(sqlQuery, message):
    let id = row[0].parseInt
    echo "This is a question id: " & $id
    return id

proc addAnswer*(conn: Dbconn, message: string, questionId: int) =
  let sqlQuery = sql"UPDATE flashcards SET answer = ? WHERE id = ?"
  conn.exec(sqlQuery, message, $questionId)

proc showAnswer*(conn: Dbconn, questionId: int, chatId: int) =
  let sqlQuery = sql"SELECT answer FROM flashcards WHERE id = ?"
  let row = conn.getRow(sqlQuery, $questionId)
  let message = row[0]
  simpleResponse(chatId, message)
  # var responseUrl = "https://api.telegram.org/bot" & botToken & "/sendMessage?chat_id=" & $chatId & "&text=" & message
  # discard client.getContent(responseUrl)
  echo message

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

proc updateFlashcardCategory*(conn: DbConn, questionId: int, newCategory: string) =
  let oldCategory = conn.getRow(sql"SELECT category FROM flashcards WHERE id = ?", questionId)
  echo "Old category: ", $oldCategory
  let query = sql"UPDATE flashcards SET category = ? WHERE id = ?"
  conn.exec(query, newCategory, questionId)
  let updatedCategory = conn.getRow(sql"SELECT category FROM flashcards WHERE id = ?", questionId)
  echo "Updated category: ", $updatedCategory

proc getFlashcardCategory*(conn: DbConn, questionId: int): string =
  var category = ""
  try:
    let row = conn.getRow(sql"SELECT category FROM flashcards WHERE id = $1", questionId)
    if row.len > 0:
      category = $row[0]
      echo "Current category of question ", questionId, " is ", category
    else:
      echo "No such flashcard with ID ", questionId
  except Exception:
    echo "Failed to get category: ", getCurrentExceptionMsg()
  return category

# proc getLatestQuestionId(conn: Dbconn): int =
#   let sqlQuery = sql"SELECT id FROM flashcards ORDER BY id DESC LIMIT 1"
#   for row in conn.rows(sqlQuery):
#     let id = row[0].parseInt
#     return id
#   return 0  # return 0 if no rows are found

proc saveLastQuestionId*(questionId: int) =
  let f = open("last_question_id.txt", fmWrite)
  f.writeLine($questionId)
  f.close()

proc readLastQuestionId*(): int =
  if fileExists("last_question_id.txt"):
    if getFileSize("last_question_id.txt") > 0:
      let f = open("last_question_id.txt", fmRead)
      let line = f.readLine()
      f.close()
      return line.parseInt
    else:
      echo "File is empty"
      return 0
  else:
    echo "File does not exist"
    return 0  # Default value if the file doesn't exist


