module.exports = (robot) ->
  robot.hear /andon$/i, (msg) ->
    if msg.room == 'faux_pas'
      robot.lights_on()

  robot.hear /andoff$/i, (msg) ->
    if msg.room == 'faux_pas'
      robot.lights_off()

  robot.lights_on ()->
    url = "https://maker.ifttt.com/trigger/lights_on/with/key/dI-HX-mjviMAz715B5ahqae5XJ1oM_hQg6ttG_UA0HP"
      robot.http(url)
        .get() (httpErr, httpRes) ->
          msg.send "@here ANDON CORD PULLED!!!"
          msg.send httpRes

  robot.lights_off ()->
    url = "https://maker.ifttt.com/trigger/lights_off/with/key/dI-HX-mjviMAz715B5ahqae5XJ1oM_hQg6ttG_UA0HP"
    robot.http(url)
      .get() (httpErr, httpRes) ->
        msg.send httpRes
