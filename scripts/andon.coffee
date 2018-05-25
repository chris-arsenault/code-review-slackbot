module.exports = (robot) ->
  robot.hear /andon$/i, (msg) ->
    url = "https://maker.ifttt.com/trigger/lights_on/with/key/dI-HX-mjviMAz715B5ahqae5XJ1oM_hQg6ttG_UA0HP"
    robot.http(url)
      .get() (httpErr, httpRes) ->
        msg.send "WORKINGish. Hold your excitment, Zack!"
        if httpErr
          msg.send httpErr
        else
          msg.send httpRes

