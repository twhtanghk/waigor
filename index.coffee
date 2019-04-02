{browser} = require 'aastocks'

class WaiGor
  contructor: ({@browser, @url}) ->
    @url ?= 'http://hkstockinvestment.blogspot.com'
    return do =>
      @browser ?= await browser()
      @

  newPage: ->
    page = await @browser.newPage()
    await page.setRequestInterception true
    page.on 'request', (req) =>
      allowed = new URL @urlTemplate
      curr = new URL req.url()
      if req.resourceType() == 'image' or curr.hostname != allowed.hostname
        req.abort()
      else
        req.continue()

  topic: ->
    try
      page = await @newPage()
      await page.got @url, waitUntil: 'networkidle2'
      await page.$ 'div.date-outer'
    catch err
      console.error err

module.exports = {WaiGor}
