import random, asyncdispatch, ../message/reply, httpclient


# let client = newHttpClient(timeout = 60_000)
# const botToken = getEnv("TG_API_TOKEN")

proc randomDelayAsync(minDelay: int, maxDelay: int): Future[void] {.async.} =
  let randomSec = rand(maxDelay - minDelay) + minDelay
  await sleepAsync(randomSec * 1000)

proc handleDoneCommandAsync*(chatId: int, callBackCheck: ptr bool) {.async.} =
  echo "callBackCheck in the beginning: " & $callBackCheck[]
  # while true:
  # let chatId = chatId
  echo "callBackCheck in the loop: " & $callBackCheck[]
  if callBackCheck[]:
    echo "chatId for simpleResponse: " & $chatId
    simpleResponse(chatId, "Confirmed")
    await randomDelayAsync(10, 25)
    callBackCheck[] = false
    echo "callBackCheck in the end: " & $callBackCheck[]
  await sleepAsync(1000)

proc handleDonePingAsync*(chatId: int) {.async.} =
  simpleResponse(chatId, "ping")
  await randomDelayAsync(10, 25)

proc delayAsync*(delayTime: int): Future[void] {.async.} =
  await sleepAsync(delayTime * 1000)

proc ping*(client: HttpClient, chatId: int, botToken: string) {.async.} =
  while true:
    # echo "empty ping"
    # if chatId == 0:
    #   return
    let responseUrl = "https://api.telegram.org/bot" & botToken & "/getMe"
    try:
      let response = client.get(responseUrl)
      if response.status == "200 OK":
        echo "successful ping"
      else:
        echo "Received unexpected status code: ", response.status
    except Exception:
      echo "Exception in ping function: ", getCurrentExceptionMsg()
    await sleepAsync(5_000)


# For example, if minDelay is 10 and maxDelay is 20:
#
# maxDelay - minDelay would be 10.
# rand(10) would then generate a random number between 0 and 9.
# Finally, adding minDelay (which is 10) would shift this range so the random number would be between 10 and 19.

# The await keyword is used to pause the current asynchronous procedure until 
# the awaited Future is complete. This is essential for proper sequencing of 
# asynchronous operations. You don't have to use await every time you call an 
# async procedure, but if you don't, the procedure will run concurrently, and 
# your current function will continue to execute without waiting for it to 
# complete.

# In Nim, the Future[T] type represents a value of type T that will be available 
# in the future. When you mark a procedure with the {.async.} pragma, the Nim 
# compiler actually transforms it into a function that returns a Future. If you 
# don't specify Future[void], the compiler will not know what type of future 
# value to expect, and you may encounter errors or unexpected behavior.

# addr: When you use addr on a variable, you get its address in memory. This 
# operation returns a pointer.
# ptr: This is a type that denotes a pointer to a variable. When defining a 
# function or procedure that takes a pointer, you use ptr to indicate that the 
# argument is expected to be a pointer to a specific type.
# In summary, addr is used to obtain the address of a variable (as a pointer), 
# while ptr is a type specifier used to indicate that a function or procedure 
# expects a pointer as an argument.
