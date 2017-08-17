module.exports = (robot) ->
  robot.startRequest = (res, command) ->
    console.log command + ' called'
    robot.seedDataStructure()
    robot.requestor = "#{res.message.user.name}"
    robot.options = robot.parseOptions(res)

  robot.endRequest = (res, command) ->
    console.log command + ' ended'

  robot.parseOptions = (res) ->
    options = {
      requestor: robot.requestor
      count: 1
      ignored_reviewers: []
      additional_reviewers: []
      additional_arguments: []
      team: undefined
      error: false
      debug: false
    }
    return options if res.match[2] == undefined

    args = res.match[2].split(' ')
    commands = {}
    while args.length != 0
      key = args.shift()
      if key[0] != '-'
        options.additional_arguments.push(key)
      else
        commands[key] = args.shift()

    for k,v of commands
      switch k
        when '-d'
          options.debug = true
        when '-t'
          options.team = v
        when '-n'
          if isFinite(v)
            options.count = parseInt(v)
          else
            options.error = true
        when '-a'
          options.additional_reviewers = v.split(' ')
        when '-i'
          options.ignored_reviewers = v.split(' ')

    return options

  robot.printList = (prefix, list, tagUsers = false) ->
    if tagUsers
      list = list.map (l) -> "@#{l}"
    else
      # splice in a random character to prevent slack for tagging everyone
      list = list.map (l) -> l.substring(0, 1) + '_' + l.substring(1)

    response = prefix
    for l in list
      response += (l + ", ")
    if list.count > 0
      response = response.substring(-1)
    return response

  robot.cleanNames = (names, allowedValues = null) ->
    cleaned_names = []
    for name in names
      if !!name
        if name.indexOf('@') != -1
          name = name.substring(1)
        if allowedValues != null && allowedValues.indexOf(name) != -1
          cleaned_names.push(name)
        else
          cleaned_names.push(name)
    return cleaned_names

  robot.subtractArray = (lhs, rhs) ->
    return lhs.filter((n) -> rhs.indexOf(n) == -1)

  robot.addArray = (lhs, rhs) ->
    for r in rhs
      lhs.push(r)
    return lhs

