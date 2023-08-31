import httpclient, json, os, strutils, ../pkg/message/reply, ../src/config, db_connector/db_postgres, ../pkg/database/database_connection

proc main() =

  let conn = open(dbHost, dbUser, dbPassword, dbName)
  # defer: conn.close()  # The connection will be closed when exiting the current scope.
  
  let botToken = getEnv("TG_API_TOKEN")
  let client = newHttpClient()  # Create a new HTTP client
  var offset = 0
  var questionId: int


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
          if incomingMessage.startsWith("/q") and not update["message"]["from"]["is_bot"].getBool:
            simpleResponse(chatId, "Added!")
            questionId = addQuestion(conn, incomingMessage[2..^1])
          if incomingMessage.startsWith("/a") and not update["message"]["from"]["is_bot"].getBool:
            simpleResponse(chatId, "Added!")
            addAnswer(conn, incomingMessage[2..^1], questionId)
          elif incomingMessage == "/list":
            showFlashcards(conn)
          # elif incomingMessage == "/start" and not update["message"]["from"]["is_bot"].getBool:
          #   staticButton(chatId, startMessage, "Add")
          else:
            echo "Enter correct command"
        except Exception:
          echo getCurrentExceptionMsg()
      offset = updateId + 1
      echo "This is offset in the end of the loop: " & $offset


main()
