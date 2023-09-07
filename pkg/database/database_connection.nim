import db_connector/db_postgres, strutils, ../../pkg/message/reply, os, #[ httpclient, ]# random, json


# let client = newHttpClient()
# const botToken = getEnv("TG_API_TOKEN")


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

proc getTotalQuestions*(conn: DbConn): int =
  let rowCount = conn.getRow(sql"SELECT COUNT(*) FROM flashcards") # The SQL COUNT() function retrieves the number of rows that match a specified condition.
  return rowCount[0].parseInt

proc minimalCount*(conn: DbConn): int =
  let query = sql"SELECT MIN(id) FROM flashcards;"
  let minRowCount = conn.getRow(query)
  let intCount = minRowCount[0].parseInt
  return intCount

proc getAllIdsAndCategories*(conn: DbConn): seq[(int, string)] =
  var all: seq[(int, string)]
  let rows = conn.getAllRows(sql"SELECT id, category FROM flashcards")
  for row in rows:
    let id = row[0].parseInt
    let category = row[1]
    all.add((id, category))
  return all

proc activateCallback*(conn: DbConn, update: JsonNode, questionId: int) =
  let callbackData = update["callback_query"]["data"].getStr
  let parts = callbackData.split("|")
  let command = parts[0]
  let chatIdFromQuery = update["callback_query"]["message"]["chat"]["id"].getInt
  if command == "show category":
    circleButtons(chatIdFromQuery, "Choose Category:", questionId)
    if command == "show answer trigger":
      echo "Currenat question id: " & $questionId
      showAnswer(conn, questionId, chatIdFromQuery)
      echo "Button was pressed"
  else:
    echo "Unrecognized callback_data: ", callbackData

proc generateQuestionId*(conn: Dbconn): int =
  var weightedList: seq[int]
  let allData = getAllIdsAndCategories(conn)
  for (id, category) in allData:
    case category
    of "hard":
      for i in 1..5: # For a flashcard with the category "hard", the code will add its ID to weightedList 5 times.
        weightedList.add(id)
    of "medium":
      for i in 1..3:
        weightedList.add(id)
    of "easy":
      for i in 1..1:
        weightedList.add(id)
  let randomIndex = rand(0..weightedList.high)
  let selectedID = weightedList[randomIndex]
  return selectedID

proc showQuestion*(conn: DbConn, randomQuestion: string, questionId: int, chatId: int) =
  inlineButton(chatId, randomQuestion, "Show Answer", "Change Category", "Done", questionId)
  echo "This is a random question: ", randomQuestion

proc questionToAsk*(conn: DbConn, chatId: int): (string, int) =
  let randomQuestionId = generateQuestionId(conn)
  let questionRow = conn.getRow(sql"SELECT question FROM flashcards WHERE id = ?", randomQuestionId)
  if questionRow.len > 0:
    let question = questionRow[0]
    return (question, randomQuestionId)
    # inlineButton(chatId, question, "Show Answer", "Change Category", randomQuestionId)
  else:
    echo "No question found for the selected ID."
    return ("", 0)

#
#   let randomSleepTime = rand(10..30)
#   sleep(randomSleepTime * 1000)
#   echo "Sleeping for " & $randomSleepTime & " seconds..."


  #   let responseUrl = "https://api.telegram.org/bot" & botToken & "/sendMessage?chat_id=" & $chatId & "&text=" & question
  #   discard client.getContent(responseUrl)
  # else:
  #   echo "No question found for the selected ID."

