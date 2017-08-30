module.exports = (robot) ->
  robot.hear /divvy-up([ ])+([a-z. 0-9,_,&,!,@,#,\$,%,\^,\*,\(,\)]*)?([\-@_a-z. 0-9]*)*$/i, (res) ->

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

  robot.hear /divvy-up-help$/i, (res) ->
    helpTest = "\nAll assignments are random.\nAll lists are space delimited.\nIf no teams are given with the -t option then it will draw team members from all teams.\n"
    usageString = "Usage:\ndivvy-up <list of items> -i <team members to ignore> -a <list of team members to add (one time only, not remembered)> -t <list of teams to pull users from>\n"
    res.send usageString + helpTest

  robot.setTeamMembers = ->
    teamMembers = {
      team_1: ['brian.palladino', 'justdroo', 'jackburum', 'joehunt', 'starr'],
      team_2: ['cameron.ivey', 'daneweber', 'hugh.gardiner', 'jenpen', 'siva'],
      team_3: ['daniel.herndon', 'dchang', 'khoi', 'glenn.espinosa', 'josh.cohen']
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
        ignoredTeamMembers.forEach (ignoredMember, index) ->
          ignoredTeamMembers[index] = ignoredMember.replace('@', '')
      else if o[0] == "a"
        addedTeamMembers = addedTeamMembers.concat(o.substring(1).split(" ").filter( (word) => return word != "" ))
        addedTeamMembers.forEach (addedMember, index) ->
          addedTeamMembers[index] = addedMember.replace('@', '')
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
      assignmentString += '@' + k + ": " + v.toString(', ') + "\n"
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
