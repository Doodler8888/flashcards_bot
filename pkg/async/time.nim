import random, asyncdispatch, ../message/reply


proc randomDelayAsync(minDelay: int, maxDelay: int): Future[void] {.async.} =
  let randomSec = rand(maxDelay - minDelay) + minDelay
  await sleepAsync(randomSec * 1000)

proc handleDoneCommandAsync*(chatId: int, callBackCheck: ptr bool) {.async.} =
  simpleResponse(chatId, "Confirmed")
  await randomDelayAsync(10, 25)
  callBackCheck[] = false

# For example, if minDelay is 10 and maxDelay is 20:
#
# maxDelay - minDelay would be 10.
# rand(10) would then generate a random number between 0 and 9.
# Finally, adding minDelay (which is 10) would shift this range so the random number would be between 10 and 19.
