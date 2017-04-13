module.exports = (robot) ->

  robot.respond /enr-cr[\ ]?(\d*)?[\ ]?([@a-z\.\ ]*)?$/i, (res) ->
    robot.seedDataStructure()
    options = robot.parseOptions(res)

    list = robot.brain.get('enr-cr')

    reviewers = []
    #add extra reviewers and put them on the back if there are any
    if options.additional_reviewers != undefined
      additional_reviewers = robot.cleanNames(options.additional_reviewers, list)
      while additional_reviewers.length != 0
        extra = additional_reviewers.shift()
        console.log extra
        console.log additional_reviewers
        reviewers.push(extra)
        list.splice(list.indexOf(extra), 1)
        list.push(extra)

    # get next count reviewers
    while options.count != 0
      # swap requestor
      if list[0] == options.requestor
        list[0] = list[1]
        list[1] = options.requestor

      # get the reviewer
      reviewers.push(list[0])

      # put reviewer on back
      list.push(list.shift())

      # next request
      options.count--

    # add @ to notify user
    robot.brain.set('enr-cr', list)
    res.send robot.printList("Assigned Reviewers: ", reviewers, true)


  robot.respond /enr-cr-set ([@a-z\.\ ]*)+$/i, (res) ->
    robot.seedDataStructure()
    cr_list = robot.cleanNames(res.match[1].split(' '))

    robot.brain.set('enr-cr', cr_list)
    res.send robot.printList("New Order: ", cr_list)

  robot.respond /enr-cr-add ([@a-z\.\ ]*)+$/i, (res) ->
    robot.seedDataStructure()
    cr_list = robot.brain.get('enr-cr')
    names = robot.cleanNames(res.match[1].split(' '))
    cr_list = robot.addArray(cr_list, names)

    robot.brain.set('enr-cr', cr_list)
    res.send robot.printList("New Order: ", cr_list)

  robot.respond /enr-cr-remove ([@a-z\.\ ]*)+$/i, (res) =>
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

  robot.parseOptions = (res) ->
    count = 1
    if (res.match[1] != undefined)
      count = res.match[1]
      unless isFinite(count)
        count = 1
        additional_reviewers = res.match[1].split(' ').map((n) -> n.trim())

    # no default
    if (res.match[2] != undefined)
      additional_reviewers = res.match[2].split(' ').map((n) -> n.trim())

    return {
      requestor: "#{res.message.user.name}"
      count: count
      additional_reviewers: additional_reviewers
    }

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
    return lhs.filter( (n) -> rhs.indexOf(n) == -1)

  robot.addArray = (lhs, rhs) ->
    for r in rhs
      lhs.push(r)
    return lhs
