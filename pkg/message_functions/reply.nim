import os, httpclient

let client = newHttpClient()

proc simpleResponse*(chatId: int, message: string) =
  const botToken = getEnv("TG_API_TOKEN")
  var responseUrl = "https://api.telegram.org/bot" & botToken & "/sendMessage?chat_id=" & $chatId & "&text=" & message
  discard client.getContent(responseUrl)


