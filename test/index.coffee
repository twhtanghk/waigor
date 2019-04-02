{WaiGor} = require '../index'

do ->
  a = await new WaiGor()
  console.log await a.topic()
