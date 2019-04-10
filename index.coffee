{browser} = require 'aastocks'
Promise = require 'bluebird'

class WaiGor
  @waitOpts:
    waitUntil: 'networkidle2'

  constructor: ({@browser, @url} = {}) ->
    @url ?= 'http://hkstockinvestment.blogspot.com'
    return do =>
      @browser ?= await browser()
      @

  newPage: ->
    page = await @browser.newPage()
    await page.setRequestInterception true
    page.on 'request', (req) =>
      allowed = new URL @url
      curr = new URL req.url()
      if req.resourceType() == 'image' or curr.hostname != allowed.hostname
        req.abort()
      else
        req.continue()

  text: (page, el) ->
    content = (el) ->
      el.textContent
    (await page.evaluate content, el).trim()

  topicIter: ->
    try
      page = await @newPage()
      await page.goto @url, WaiGor.waitOpts
      _this = @
      curr = ->
        for i in await page.$$ '.date-outer'
          date = await _this.text page, await i.$('.date-header > span')
          for j in await i.$$ '.date-posts > .post-outer > .post > h3 > a'
            link = await (await j.getProperty 'href').jsonValue()
            yield {date, link}
      while true
        for await i from curr()
          yield i
        await Promise.all [
          page.waitForSelector 'a.blog-pager-older-link'
          page.click 'a.blog-pager-older-link'
          page.waitForNavigation WaiGor.waitOpts
        ]
    finally 
      await page.close()

  postIter: ({date, link}) ->
    try
      page = await @newPage()
      await page.goto link, WaiGor.waitOpts
      while true
        elem = await page.$ '.loadmore'
        if null == await elem.$ '.hidden'
          break
        else
          await Promise.all [
            page.waitForSelector '.loadmore a'
            page.click '.loadmore a'
            page.waitForNavigation WaiGor.waitOpts
          ]
      for i in await page.$$ 'li.comment .comment-block'
        user = await @text page, await i.$('.comment-header > cite > a')
        date = await @text page, await i.$('.comment-header > .datetime > a')
        content = await @text page, await i.$('.comment-content')
        yield {user, date, content}
    finally 
      await page.close()
    
module.exports = {WaiGor}
