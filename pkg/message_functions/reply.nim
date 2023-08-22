import os, httpclient, json


const botToken = getEnv("TG_API_TOKEN")

let client = newHttpClient()
let url = "https://api.telegram.org/bot" & botToken & "/sendMessage"
let headers = newHttpHeaders({"Content-Type": "application/json"})

# let button = %*{
#   "inline_keyboard": [[{"text": "Your Button Text", "callback_data": "your_callback_data"}]]
# }


proc simpleResponse*(chatId: int, message: string) =
  var responseUrl = "https://api.telegram.org/bot" & botToken & "/sendMessage?chat_id=" & $chatId & "&text=" & message
  discard client.getContent(responseUrl)


proc sendButton*(chatId: int, text: string) =
  let payload = %*{
    "chat_id": chatId,
    "text": text,
    "reply_markup": {
      "inline_keyboard": [
        [{"text": "Option 1", "callback_data": "1"}],
        # [{"text": "Option 2", "callback_data": "2"}]
      ]
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
