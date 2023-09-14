import std/[httpclient, json, os, strutils, times, random], ../pkg/message/reply, #[ ../src/config, ]# db_connector/db_postgres, ../pkg/database/database_connection

proc main() =

  const dbHost = getEnv("DBHOST")
  const dbUser = getEnv("DBUSER")
  const dbPassword = getEnv("DBPASSWORD")
  const dbName = getEnv("DBNAME")

  let conn = open(dbHost, dbUser, dbPassword, dbName)
  defer: conn.close()  # The connection will be closed when exiting the current scope.
  
  let botToken = getEnv("TG_API_TOKEN")
  let client = newHttpClient(#[ timeout = 60_000 ]#)
  var offset = 0
  var questionId: int
  var questionMessage = false
  var textCheck = false
  var chatId = 0
  var chatIdFromQuery = 0
  var command = ""
  var callBackCheck = false
  var nextMutationTime: float = 0
  var randomQuestionId = 0


  # if testConnection(conn):
  #   echo "Connection is working!"
  # else:
  #   echo "Connection failed!"
  
  
  while true:
    let currentTime = epochTime()
    if currentTime >= nextMutationTime and nextMutationTime > 0:
      callBackCheck = false  # Resetting callBackCheck
      nextMutationTime = 0  # Reset nextMutationTime

    let url = "https://api.telegram.org/bot" & botToken & "/getUpdates?offset=" & $offset
    let response = client.getContent(url)  # Send the request
    let updates = parseJson(response)  # Parse the JSON response
    if not callBackCheck:
      let (rquestion, rquestionId) = questionToAsk(conn, chatId)
      inlineButton(chatId, rquestion, "Show Answer", "Change Category", "Done", rquestionId)
      callBackCheck = true
  
    for update in updates["result"]:
      if questionId == 0:
        questionId = readLastQuestionId()
      let updateId = update["update_id"].getInt
      if "callback_query" in update:
        echo "chatId on callback_query loop check: " & $chatId
        callBackCheck = true
        let callbackData = update["callback_query"]["data"].getStr
        let parts = callbackData.split("|")
        command = parts[0]
        chatIdFromQuery = update["callback_query"]["message"]["chat"]["id"].getInt
        echo "chatIdFromQuery before the Done check: " & $chatIdFromQuery
        if command == "Done":
          nextMutationTime = currentTime + float(rand(4000..6020))
          simpleResponse(chatIdFromQuery, "Confirmed!")
        elif command == "show category":
          circleButtons(chatIdFromQuery, "Choose Category:", questionId)
        elif parts.len >= 2:
          questionId = parts[1].parseInt
          if command == "show answer trigger":
            showAnswer(conn, questionId, chatIdFromQuery)
        else:
          echo "Unrecognized callback_data: ", callbackData
      elif "message" in update:
        chatId = update["message"]["chat"]["id"].getInt
        let messageText = update["message"]["text"].getStr
        var caseCheck = false
        case messageText
        of "🔴 Hard":
          echo "Hard was selected"
          if questionId != 0:  # Assuming 0 is an invalid value for questionId
            updateFlashcardCategory(conn, randomQuestionId, "hard")
          else:
            echo "questionId is not initialized."
        of "🟡 Medium":
          echo "Medium was selected"
          if questionId != 0:  # Assuming 0 is an invalid value for questionId
            updateFlashcardCategory(conn, randomQuestionId, "medium")
          else:
            echo "questionId is not initialized."
        of "🟢 Easy":
          echo "Easy was selected"
          if questionId != 0:  # Assuming 0 is an invalid value for questionId
            updateFlashcardCategory(conn, randomQuestionId, "easy")
          else:
            echo "questionId is not initialized."
        else:
          caseCheck = true
        if "text" in update["message"] and caseCheck:
            try:
              textCheck = true
              let incomingMessage = update["message"]["text"].getStr
              if incomingMessage.startsWith("/add") and not update["message"]["from"]["is_bot"].getBool:
                questionId = addQuestion(conn, incomingMessage[5..^1])
                simpleResponse(chatId, "Write your answer:")
                if not update["message"]["text"].getStr.startsWith("Write") and not update["message"]["from"]["is_bot"].getBool:
                  simpleResponse(chatId, "Write your answer:")
                questionMessage = true
              elif not incomingMessage.startsWith("/add") and questionMessage:
                addAnswer(conn, incomingMessage, questionId)
                questionMessage = false
                simpleResponse(chatId, "Flashcard created")
              elif incomingMessage.startsWith("/ask"):
                randomQuestionId = generateQuestionId(conn)
                let query = sql"SELECT question FROM flashcards WHERE id = ?"
                let randomQuestionRow = conn.getRow(query, randomQuestionId)
                if randomQuestionRow.len > 0:
                  let randomQuestion = $randomQuestionRow[0]  
                  echo "chatId when using ask: " & $chatId & " and randomQuestionId: " & $randomQuestionId
                  inlineButton(chatId, randomQuestion, "Show Answer", "Change Category", "Done", randomQuestionId)
                else:
                  echo "The query returned an empty row."
              elif incomingMessage.startsWith("/list"):
                showFlashcards(conn)
              elif incomingMessage.startsWith("/start"):
                callBackCheck = false
              elif incomingMessage == "Confirmed":
                continue
              else:
                echo "Enter a correct command"
            except Exception:
              echo getCurrentExceptionMsg()
        else:
          if not caseCheck and not textCheck:
            echo "Unrecognized message: ", messageText

      offset = updateId + 1
      # echo "This is offset in the end of the loop: " & $offset
      saveLastQuestionId(questionId)


main()
