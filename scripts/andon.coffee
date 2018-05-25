module.exports = (robot) ->
  robot.respond /andon$/i, (msg) ->
    msg.send JSON.Stringify(msg)
    url = "https://maker.ifttt.com/trigger/lights_on/with/key/dI-HX-mjviMAz715B5ahqae5XJ1oM_hQg6ttG_UA0HP"

    msg.http(url)
      .get (httpErr, httpRes) ->
        msg.send httpRes
        msg.send httpErr
