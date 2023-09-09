import os, httpclient, json, random, uri, #[ ../async/time, ]# #[ asyncdispatch ]# chronos


const botToken = getEnv("TG_API_TOKEN")

let client = newHttpClient(timeout = 60_000)  # Create a new HTTP client
let url = "https://api.telegram.org/bot" & botToken & "/sendMessage"
let headers = newHttpHeaders({"Content-Type": "application/json"})


proc simpleResponse*(chatId: int, message: string) =
  try:
    let encodedMessage = encodeUrl(message)
    var responseUrl = "https://api.telegram.org/bot" & botToken & "/sendMessage?chat_id=" & $chatId & "&text=" & encodedMessage
    # echo "chatId in simpleResponse: " & $chatId
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
  var attempts = 0
  let body = payload.pretty(2)
  while attempts < 3:
    try:
      let answer = client.request(url, httpMethod = HttpPost, body = body, headers = headers)
      if answer.status == "200 OK":
        break
      else:
        echo "Received unexpected status code: ", answer.status
    except Exception:
      echo getCurrentExceptionMsg()
    attempts += 1
    if attempts == 3:
      echo "Request failed after 3 attempts."




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

# proc delayAsync*(delayTime: int): Future[void] {.async.} =
#   await sleepAsync(delayTime * 1000)
#
# proc ping*(chatId: int, client: HttpClient) {.async.} =
#   while true:
#     if chatId == 0:
#       continue
#     let responseUrl = "https://api.telegram.org/bot" & botToken & "/getMe"
#     try:
#       discard client.getContent(responseUrl)
#       echo "ping"
#     except Exception:
#       echo getCurrentExceptionMsg()
#     asyncCheck sleepAsync(60_000)  # delay for 60 seconds

# proc callPingEvery60Seconds*(chatId: int) {.async.} =
#   while true:
#     await ping(chatId)
#     await sleepAsync(60_000)  # wait for 60 seconds


# %* operator is a Nim shorthand for parsing a JSON literal.

# {"text": "Your Button Text", "callback_data": "your_callback_data"}:
# Each object in the inner arrays represents a button on the inline keyboard.
# The "text" key specifies the text to be displayed on the button,
# and the "callback_data" key specifies a unique identifier for the button's 
# action.
