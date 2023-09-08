import httpclient, json, os, strutils, ../pkg/message/reply, ../src/config, db_connector/db_postgres, ../pkg/database/database_connection, ../pkg/async/time, asyncdispatch

proc main() {.async.} =

  let conn = open(dbHost, dbUser, dbPassword, dbName)
  defer: conn.close()  # The connection will be closed when exiting the current scope.
  
  let botToken = getEnv("TG_API_TOKEN")
  let client = newHttpClient(timeout = 60_000)  # Create a new HTTP client
  var offset = 0
  var questionId: int
  var questionMessage = false
  var textCheck = false
  var chatId = 0
  var chatIdFromQuery = 0
  var callBackCheck = false
  var command = ""


  # if testConnection(conn):
  #   echo "Connection is working!"
  # else:
  #   echo "Connection failed!"
  
  
  # await callPingEvery60Seconds(chatId)
  # asyncCheck ping(client, chatId, botToken)
  while true:
    # await sleepAsync(250)
    # await handleDoneCommandAsync(chatId)
    let url = "https://api.telegram.org/bot" & botToken & "/getUpdates?offset=" & $offset
    # echo "url: " & url
    let response = client.getContent(url)  # Send the request
    # echo "response: " & response
    let updates = parseJson(response)  # Parse the JSON response
    if not callBackCheck:
      echo "Before calling the inlineButton " & $callBackCheck
      echo "chatId before calling the inlineButton: " & $chatId
      let (rquestion, rquestionId) = questionToAsk(conn, chatId)
      inlineButton(chatId, rquestion, "Show Answer", "Change Category", "Done", rquestionId)
      callBackCheck = true
      echo "After calling the inlineButton " & $callBackCheck
      echo "chatId after calling the inlineButton: " & $chatId
  
    for update in updates["result"]:
      if questionId == 0:
        questionId = readLastQuestionId()
        # echo "readLastQuestion activated"
        # echo "This is questionId: at the start of the loop: " & $questionId
      let updateId = update["update_id"].getInt
      # echo "This is updateId: " & $updateId
      if "callback_query" in update:
        echo "chatId on callback_query loop check: " & $chatId
        callBackCheck = true
        let callbackData = update["callback_query"]["data"].getStr
        let parts = callbackData.split("|")
        command = parts[0]
        chatIdFromQuery = update["callback_query"]["message"]["chat"]["id"].getInt
        echo chatIdFromQuery
        if command == "Done":
          await handleDoneCommandAsync(chatIdFromQuery, addr callBackCheck)
        elif command == "show category":
          circleButtons(chatIdFromQuery, "Choose Category:", questionId)
        elif parts.len >= 2:
          # echo "Reached before parsing"
          questionId = parts[1].parseInt
          # echo "Reached after parsing"
          if command == "show answer trigger":
            # echo "Currenat question id: " & $questionId
            showAnswer(conn, questionId, chatIdFromQuery)
            # echo "Button was pressed"
        else:
          echo "Unrecognized callback_data: ", callbackData
      elif "message" in update:
        chatId = update["message"]["chat"]["id"].getInt
        let messageText = update["message"]["text"].getStr
        var caseCheck = false
        case messageText
        of "🔴 Hard":
          echo "Hard was selected"
          # updateFlashcardCategory(conn, questionId, "hard")
          if questionId != 0:  # Assuming 0 is an invalid value for questionId
            # echo "This is questionId: " & $questionId
            updateFlashcardCategory(conn, questionId, "hard")
          else:
            echo "questionId is not initialized."
        of "🟡 Medium":
          echo "Medium was selected"
          if questionId != 0:  # Assuming 0 is an invalid value for questionId
            # echo "This is questionId: " & $questionId
            updateFlashcardCategory(conn, questionId, "medium")
          else:
            echo "questionId is not initialized."
        of "🟢 Easy":
          echo "Easy was selected"
          if questionId != 0:  # Assuming 0 is an invalid value for questionId
            # echo "This is questionId: " & $questionId
            updateFlashcardCategory(conn, questionId, "easy")
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
                questionMessage = true
              elif not incomingMessage.startsWith("/add") and questionMessage:
                addAnswer(conn, incomingMessage, questionId)
                questionMessage = false
                simpleResponse(chatId, "Flashcard created")
              elif incomingMessage.startsWith("/ask"):
                let randomQuestionId = generateQuestionId(conn)
                # echo "This is a random question id: " & $randomQuestionId
                let query = sql"SELECT question FROM flashcards WHERE id = ?"
                let randomQuestionRow = conn.getRow(query, randomQuestionId)
                # echo "This is a random question row: ", $randomQuestionRow
                # echo "Length of randomQuestionRow: ", randomQuestionRow.len
                if randomQuestionRow.len > 0:
                  let randomQuestion = $randomQuestionRow[0]  
                  inlineButton(chatId, randomQuestion, "Show Answer", "Change Category", "Done", randomQuestionId)
                  # echo "This is a random question: ", randomQuestion
                else:
                  echo "The query returned an empty row."
              elif incomingMessage.startsWith("/list"):
                # echo "Showing flashcards..."
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


waitFor main()
