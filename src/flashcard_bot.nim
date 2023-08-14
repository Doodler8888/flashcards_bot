import httpclient, json, os

let botToken = getEnv("TG_API_TOKEN")
let client = newHttpClient()  # Create a new HTTP client
var offset = 0  # Initialize the offset

while true:  # Loop indefinitely
  let url = "https://api.telegram.org/bot" & botToken & "/getUpdates?offset=" & $offset
  let response = client.getContent(url)  # Send the request
  let updates = parseJson(response)  # Parse the JSON response

  for update in updates["result"]:
    let updateId = update["update_id"].getInt
    let chatId = update["message"]["chat"]["id"].getInt

    if "message" in update and not update["message"]["from"]["is_bot"].getBool:
      # Send a response back to the user
      let responseUrl = "https://api.telegram.org/bot" & botToken & "/sendMessage?chat_id=" & $chatId & "&text=Hello, I'm your bot!"
      discard client.getContent(responseUrl)
      offset = updateId + 1


  









  # 
  #   if updateId >= offset:
  #     offset = update["update_id"].getInt + 1
