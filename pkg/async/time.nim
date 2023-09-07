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
