import httpclient, json, os, strutils, ../pkg/message/reply, ../src/config, db_connector/db_postgres, ../pkg/database/database_connection

proc main() =

  let conn = open(dbHost, dbUser, dbPassword, dbName)
  # defer: conn.close()  # The connection will be closed when exiting the current scope.
  
  let botToken = getEnv("TG_API_TOKEN")
  let client = newHttpClient()  # Create a new HTTP client
  var offset = 0
  var questionId: int
  var questionMessage = false


  if testConnection(conn):
    echo "Connection is working!"
  else:
    echo "Connection failed!"
  
  
  while true:
    let url = "https://api.telegram.org/bot" & botToken & "/getUpdates?offset=" & $offset
    let response = client.getContent(url)  # Send the request
    let updates = parseJson(response)  # Parse the JSON response
    echo "This is offset in the start of the loop: " & $offset
  
    for update in updates["result"]:
      let updateId = update["update_id"].getInt
      echo "This is updateId: " & $updateId
      let chatId = update["message"]["chat"]["id"].getInt
      if "text" in update["message"]:
        try:
          let incomingMessage = update["message"]["text"].getStr
          if incomingMessage.startsWith("/add") and not update["message"]["from"]["is_bot"].getBool:
            questionId = addQuestion(conn, incomingMessage[2..^1])
            simpleResponse(chatId, "Write your answer:")
            questionMessage = true
          elif not incomingMessage.startsWith("/add") and questionMessage:
            addAnswer(conn, incomingMessage, questionId)
            questionMessage = false
          elif incomingMessage.startsWith("/ask"):
            let randomQuestionRow = conn.getRow(sql"SELECT question FROM flashcards ORDER BY RANDOM() LIMIT 1")
            let randomQuestion = randomQuestionRow[0]
            var responseUrl = "https://api.telegram.org/bot" & botToken & "/sendMessage?chat_id=" & $chatId & "&text=" & randomQuestion
            discard client.getContent(responseUrl)

          elif incomingMessage.startsWith("/list"):
            echo "Showing flashcards..."
            showFlashcards(conn)
          else:
            echo "Enter a correct command"
        except Exception:
          echo getCurrentExceptionMsg()
      offset = updateId + 1
      echo "This is offset in the end of the loop: " & $offset


main()
