import os, httpclient, json, random, uri


const botToken = getEnv("TG_API_TOKEN")

let client = newHttpClient()
let url = "https://api.telegram.org/bot" & botToken & "/sendMessage"
let headers = newHttpHeaders({"Content-Type": "application/json"})


proc simpleResponse*(chatId: int, message: string) =
  try:
    let encodedMessage = encodeUrl(message)
    var responseUrl = "https://api.telegram.org/bot" & botToken & "/sendMessage?chat_id=" & $chatId & "&text=" & encodedMessage
    echo "chatId in simpleResponse: " & $chatId
    discard client.getContent(responseUrl)
  except Exception:
    echo getCurrentExceptionMsg()


proc inlineButton*(chatId: int, text: string, buttonText: string, buttonText2: string, buttonText3: string, questionId: int) =
  let payload = %*{
    "chat_id": chatId,
    "text": text,
    "reply_markup": {
      "inline_keyboard": [
        [{"text": buttonText, "callback_data": "show answer trigger|" & $questionId}],
        [{"text": buttonText2, "callback_data": "show category|"}],
        [{"text": buttonText3, "callback_data": "Done|"}],
      ]
    }
  }
  let body = payload.pretty(2)
  discard client.request(url, httpMethod = HttpPost, body = body, headers = headers)


proc circleButtons*(chatId: int, text: string, questionId: int) =
  let payload = %*{
    "chat_id": chatId,
    "text": text,
    "reply_markup": {
      "keyboard": [
        [
          {"text": "🔴 Hard"},
          {"text": "🟡 Medium"},
          {"text": "🟢 Easy"}
        ]
      ],
      "resize_keyboard": true
    }
  }
  let body = payload.pretty(2)
  discard client.request(url, httpMethod = HttpPost, body = body, headers = headers)


proc randomSleep*(minSeconds: int, maxSeconds: int) =
  let sleepTime = rand(minSeconds..maxSeconds)
  echo "Sleeping for ", sleepTime, " seconds."
  sleep(sleepTime * 1000)


proc makeRequest*() =
  let url = "http://some.api.endpoint"
  let headers = newHttpHeaders()
  headers.add("Authorization", "Bearer your_token_here")
  headers.add("Other-Header", "header_value")

  # Log the URL and headers for debugging
  echo "URL: ", url
  echo "Headers: ", headers

  discard getContent(client, url)



# proc inlineButtonCircles*(chatId: int, text: string, questionId: int) =
#   let payload = %*{
#     "chat_id": chatId,
#     "text": text,
#     "reply_markup": {
#       "keyboard": [
#         [
#           {"text": "🔴", "callback_data": "red|" & $questionId},
#           {"text": "🟡", "callback_data": "yellow|" & $questionId},
#           {"text": "🟢", "callback_data": "green|" & $questionId}
#         ]
#       ]
#     }
#   }
#   let body = payload.pretty(2)
#   discard client.request(url, httpMethod = HttpPost, body = body, headers = headers)


proc staticButton*(chatId: int, text: string, buttonText: string) =
  let payload = %*{
    "chat_id": chatId,
    "text": text,
    "reply_markup": {
      "keyboard": [[{"text": buttonText}]],
      "resize_keyboard": true
    }
  }
  let body = payload.pretty(2)
  discard client.request(url, httpMethod = HttpPost, body = body, headers = headers)





# %* operator is a Nim shorthand for parsing a JSON literal.

# {"text": "Your Button Text", "callback_data": "your_callback_data"}:
# Each object in the inner arrays represents a button on the inline keyboard.
# The "text" key specifies the text to be displayed on the button,
# and the "callback_data" key specifies a unique identifier for the button's 
# action.
