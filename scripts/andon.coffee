module.exports = (robot) ->
  robot.respond /andon$/i, (res) ->
    console.log 'andon called'

    url = "https://maker.ifttt.com/trigger/lights_on/with/key/dI-HX-mjviMAz715B5ahqae5XJ1oM_hQg6ttG_UA0HP"

    res.http(url)
      .header('Content-Type', 'application/json')
      .get (err, res) ->
        console.log 'post'
