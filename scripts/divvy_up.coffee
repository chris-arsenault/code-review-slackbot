module.exports = (robot) ->
  robot.hear /divvy-up([ ])?(.*)$/i, (res) ->
    robot.requestor = "#{res.message.user.name}"
    console.log("divvy-up called")

    teamMembers = robot.getList()
    items = robot.getItems(res)
    randomizedItems = robot.shuffleArray(items)
    randomizedMembers = robot.shuffleArray(teamMembers)

    assignedItems = robot.assign(randomizedItems, randomizedMembers)
    res.send "Assignments \n" + robot.printAssignments(assignedItems)

    console.log 'divvy-up ended'

  robot.shuffleArray = (array) ->
    return array.sort () =>
      Math.random() - 0.5

  robot.getItems = (res) ->
    res.match[2].split(',');

  robot.printAssignments = (assignedItems) ->
    assignmentString = ""
    for k, v of assignedItems
      assignmentString += k + ": " + v.toString(', ') + "\n"
    assignmentString

  robot.assign = (items, teamMembers, assignedItems={}, itemIndex=0) ->
    teamMembers.forEach (member) ->
      if items[itemIndex] != undefined
        if assignedItems[member] == undefined
          assignedItems[member] = [items[itemIndex]]
        else
          assignedItems[member].push(items[itemIndex])
        itemIndex += 1

    rawValues = robot.getValues(assignedItems)

    assignedValues = rawValues.reduce (a, b) ->
      a.concat(b)

    if items.length > assignedValues.length
      robot.assign(items, teamMembers, assignedItems, itemIndex)

    assignedItems

  robot.flattenArray = (array) ->
    array.reduce (a, b) ->
      a.concat(b)

  robot.getValues = (object) ->
    Object.keys(object).map (key) ->
      object[key]
