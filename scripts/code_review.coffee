module.exports = (robot) ->

  # /enr-cr[\ ]?(\d*)?[\ ]?([@a-z\.\ ]*)?$/i
  robot.respond /enr-cr([ ])?([\-@a-z. 0-9]*)?$/i, (res) ->
    robot.seedDataStructure()
    options = robot.parseOptions(res)

    if !options
      return

    if options.error
      res.send robot.usageString()
      return


    list = robot.brain.get('enr-cr')

    reviewers = []
    #add extra reviewers and put them on the back if there are any
    if options.additional_reviewers != undefined
      additional_reviewers = robot.cleanNames(options.additional_reviewers, list)
      while additional_reviewers.length != 0
        extra = additional_reviewers.shift()
        reviewers.push(extra)
        list.splice(list.indexOf(extra), 1)
        list.push(extra)

    # get next count reviewers
    options.igonored_reviewers.push(options.requestor)
    ignored_reviewers = robot.cleanNames(options.igonored_reviewers, list)
    if ignored_reviewers.count > list.count
      res.send "Too many people ignored!"
      return

    while options.count != 0
      # inorder list of available people
      available_reviewers = robot.subtractArray(list, ignored_reviewers)
      if available_reviewers.count < 1
        res.send "No available reviewers!"
        return

      next_reviewer = available_reviewers[0]

      # remove them
      list.splice(list.indexOf(next_reviewer), 1)

      # get the reviewer
      reviewers.push(next_reviewer)

      # put reviewer on back
      list.push(next_reviewer)

      # next request
      options.count--

    robot.brain.set('enr-cr', list)
    res.send robot.printList("Assigned Reviewers: ", reviewers, true)


  robot.respond /enr-cr-set ([@a-z. ]*)+$/i, (res) ->
    robot.seedDataStructure()
    cr_list = robot.cleanNames(res.match[1].split(' '))

    robot.brain.set('enr-cr', cr_list)
    res.send robot.printList("New Order: ", cr_list)

  robot.respond /enr-cr-add ([@a-z. ]*)+$/i, (res) ->
    robot.seedDataStructure()
    cr_list = robot.brain.get('enr-cr')
    names = robot.cleanNames(res.match[1].split(' '))
    cr_list = robot.addArray(cr_list, names)

    robot.brain.set('enr-cr', cr_list)
    res.send robot.printList("New Order: ", cr_list)

  robot.respond /enr-cr-remove ([@a-z. ]*)+$/i, (res) =>
    robot.seedDataStructure()
    cr_list = robot.brain.get('enr-cr')
    names = robot.cleanNames(res.match[1].split(' '), cr_list)
    cr_list = robot.subtractArray(cr_list, names)

    robot.brain.set('enr-cr', cr_list)
    res.send robot.printList("New Order: ", cr_list)

  robot.respond /enr-cr-order/i, (res) ->
    robot.seedDataStructure()
    cr_list = robot.brain.get('enr-cr')
    res.send robot.printList("Current Order: ", cr_list)

  robot.respond /enr-cr-reset$/i, (res) ->
    robot.resetDataStructure()
    cr_list = robot.brain.get('enr-cr')
    res.send robot.printList("New Order: ", cr_list)

#### HELPERS ###

  robot.usageString = () ->
    "enr-cr -n <number_of_random_reviewers> -i <list_of_ignored_users> -a <list_of_additional_reviewers>"

  robot.parseOptions = (res) ->
    if (res.match[1] == undefined && res.match[2] == undefined)
      return robot.parseArgs(res)

    if (res.match[1] != ' ' || res.match[2] == undefined)
      return false

    return robot.parseArgs(res)

  robot.parseArgs = (res) ->

    options = {
      requestor: "#{res.message.user.name}"
      count: 1
      error: false
      igonored_reviewers: []
    }
    return options if res.match[2] == undefined

    args = res.match[2].split(' ')
    commands = {}
    while args.length != 0
      key = args.shift()
      if key[0] != '-'
        options.error = true
      value = ""
      while args.length != 0 && args[0][0] != '-'
        value += args.shift()
        value += " "
      value.substring(-1)
      commands[key] = value

    for k,v of commands
      switch k
        when '-n'
          if isFinite(v)
            options.count = parseInt(v)
          else
            options.error = true
        when '-a'
          options.additional_reviewers = v.split(' ')
        when '-i'
          options.igonored_reviewers = v.split(' ')

    return options

  robot.seedDataStructure = ->
    data = robot.brain.get('enr-cr')
    if data == null
      robot.resetDataStructure()

  robot.resetDataStructure = ->
    data =["chris.arsenault", "josh.cohen", "jenpen", "joehunt", "starr", "cameron.ivery", "khoi", "jackburum", "siva"]
    robot.brain.set('enr-cr', data)


  robot.printList = (prefix, list, tagUsers = false) ->
    if tagUsers
      list = list.map (l) -> "@#{l}"
    else
      # splice in a random character to prevent slack for tagging everyone
      list = list.map (l) -> l #l.substring(0, 1) + '_' + l.substring(1)

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
    return lhs.filter( (n) -> rhs.indexOf(n) == -1)

  robot.addArray = (lhs, rhs) ->
    for r in rhs
      lhs.push(r)
    return lhs
