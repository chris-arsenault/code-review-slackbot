module.exports = (robot) ->
  robot.hear /divvy-up([ ])?([a-z. 0-9,_,&,!,@,#,\$,%,\^,\*,\(,\)]*)?([\-@_a-z. 0-9]*)*$/i, (res) ->

    console.log("divvy-up called")

    robot.requestor = "#{res.message.user.name}"
    robot.setTeamMembers()

    options = robot.getOptions(res)
    teamMembers = robot.getTeamMembers(res, options.ignoredTeamMembers, options.addedTeamMembers, options.teams)
    items = robot.getItems(res)

    randomizedItems = robot.shuffleArray(items)
    randomizedMembers = robot.shuffleArray(teamMembers)

    assignedItems = robot.assign(randomizedItems, randomizedMembers)
    res.send "Assignments \n" + robot.printAssignments(assignedItems)

    console.log 'divvy-up ended'

  robot.setTeamMembers = ->
    teamMembers = {
      team_1: ['Brian', 'Drew', 'Jack', 'Joe', 'Starr'],
      team_2: ['Cameron', 'Dane', 'Hugh', 'Jen', 'Siva'],
      team_3: ['Daniel', 'David', 'Khoi', 'Glenn', 'Josh']
    }
    robot.brain.set('teamMembers', teamMembers)

  robot.getOptions = (res) ->
    if res.match[3] == undefined
      return {}
    allOptions = res.match[3].split("-").splice(1)
    ignoredTeamMembers = []
    addedTeamMembers = []
    teams = []
    allOptions.forEach (o) ->
      if o[0] == "i"
        ignoredTeamMembers = ignoredTeamMembers.concat(o.substring(1).split(" ").filter( (word) => return word != "" ))
      else if o[0] == "a"
        addedTeamMembers = addedTeamMembers.concat(o.substring(1).split(" ").filter( (word) => return word != "" ))
      else if o[0] == "t"
        teams = teams.concat(o.substring(1).split(" ").filter( (word) => return word != "" ))

    { "ignoredTeamMembers" : ignoredTeamMembers, "addedTeamMembers" : addedTeamMembers, "teams": teams}

  robot.getTeamMembers = (res, ignored = [], added = [], teams = []) ->
    allTeamMembers = robot.brain.get('teamMembers')
    requestedMembers = []

    if teams.length > 0
      teams.forEach (team) ->
        requestedMembers = requestedMembers.concat(allTeamMembers[team])
    else
      requestedMembers = robot.getValues(allTeamMembers)
      requestedMembers = robot.flattenArray(requestedMembers)

    ignored.forEach (ignoredMember) ->
      index = requestedMembers.indexOf(ignoredMember)
      if index != -1
        requestedMembers.splice(index, 1)

    requestedMembers.concat(added)

  robot.getItems = (res) ->
    if res.match[2] == undefined
      return []
    res.match[2].replace(/^\s+|\s+$/g, "").split(' ');

  robot.printAssignments = (assignedItems) ->
    assignmentString = ""
    if Object.keys(assignedItems).length == 0
      return "No items given!"

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

    if rawValues.length == 0
      return {}

    assignedValues = rawValues.reduce (a, b) ->
      a.concat(b)

    if items.length > assignedValues.length
      robot.assign(items, teamMembers, assignedItems, itemIndex)

    assignedItems
