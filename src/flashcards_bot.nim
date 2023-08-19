import httpclient, json, os, strutils, ../pkg/message_functions/reply, ../src/config, db_connector/db_postgres, ../pkg/database/database_connection

proc main() =

  let conn = open(dbHost, dbUser, dbPassword, dbName)
  # defer: conn.close()  # The connection will be closed when exiting the current scope.
  
  let botToken = getEnv("TG_API_TOKEN")
  let client = newHttpClient()  # Create a new HTTP client
  var offset = 0

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
            reply.simpleResponse(chatId, "Added!")
            echo "This is incomingMessage: " & incomingMessage
            let textToAdd = incomingMessage[5..^1]
            addMessage(conn, textToAdd)
          elif incomingMessage == "/list":
            getMessages(conn)
        except Exception:
          echo getCurrentExceptionMsg()
      offset = updateId + 1
      echo "This is offset in the end of the loop: " & $offset


main()



# ^1: This is shorthand for "one index from the end of the string." 
# The ^ operator in Nim is a convenient way to refer to indices from the 
# end of a collection. So ^1 refers to the second-to-last index, ^2 to the 
# third-to-last, and so on. Using ^0 would refer to the last index,
# but since Nim slices are end-exclusive, we use ^1 to include the last 
# character in the slice.
