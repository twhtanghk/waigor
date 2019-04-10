{WaiGor} = require '../index'

do ->
  a = await new WaiGor()
  for await i from a.topicIter()
    for await j from a.postIter i 
      console.log j
