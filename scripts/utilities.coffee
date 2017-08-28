module.exports = (robot) ->
  robot.flattenArray = (array) ->
    array.reduce (a, b) ->
      a.concat(b)

  robot.getValues = (object) ->
    Object.keys(object).map (key) ->
      object[key]

  robot.shuffleArray = (array) ->
    return array.sort () =>
      Math.random() - 0.5
