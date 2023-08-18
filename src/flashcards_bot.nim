import httpclient, json, os, ../pkg/message_functions/reply

let botToken = getEnv("TG_API_TOKEN")
let client = newHttpClient()  # Create a new HTTP client
var offset = 0


while true:
  let url = "https://api.telegram.org/bot" & botToken & "/getUpdates?offset=" & $offset
  let response = client.getContent(url)  # Send the request
  let updates = parseJson(response)  # Parse the JSON response

  for update in updates["result"]:
    let updateId = update["update_id"].getInt
    let chatId = update["message"]["chat"]["id"].getInt
    if "text" in update["message"]:
      try:
        let incomingMessage = update["message"]["text"].getStr
        if incomingMessage == "/add" and not update["message"]["from"]["is_bot"].getBool:
          reply.simpleResponse(chatId, "Added!")
      except:
        continue
    offset = updateId + 1
