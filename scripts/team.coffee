module.exports = (robot) ->
  robot.hear /eve-team-set([ ])?([\-@a-z. 0-9]*)?$/i, (res) ->
    robot.startRequest(res, 'eve-team-set')
    cr_list = robot.cleanNames(robot.options.additional_arguments)

    robot.setList(cr_list)
    res.send robot.printList("New Order: ", cr_list)
    robot.endRequest(res, 'eve-team-set')

  robot.hear /eve-team-add([ ])?([\-@a-z. 0-9]*)?$/i, (res) ->
    robot.startRequest(res, 'eve-team-add')
    cr_list = robot.getList()
    names = robot.cleanNames(robot.options.additional_arguments)
    cr_list = robot.addArray(cr_list, names)

    robot.setList(cr_list)
    res.send robot.printList("New Order: ", cr_list)
    robot.endRequest(res, 'eve-team-add')

  robot.hear /eve-team-remove([ ])?([\-@a-z. 0-9]*)?/i, (res) =>
    robot.startRequest(res, 'eve-team-remove')
    cr_list = robot.getList()
    names = robot.cleanNames(robot.options.additional_arguments, cr_list)
    cr_list = robot.subtractArray(cr_list, names)

    robot.setList(cr_list)
    res.send robot.printList("New Order: ", cr_list)
    robot.endRequest(res, 'eve-team-remove')

  robot.hear /eve-team-order([ ])?([\-@a-z. 0-9]*)?/i, (res) ->
    robot.startRequest(res, 'eve-team-order')
    cr_list = robot.getList()
    res.send robot.printList("Current Order: ", cr_list)
    robot.endRequest(res, 'eve-team-order')

  robot.hear /eve-team-reset([ ])?([\-@a-z. 0-9]*)?$/i, (res) ->
    robot.startRequest(res, 'eve-team-reset')
    robot.resetDataStructure()
    cr_list = robot.getList()
    res.send robot.printList("New Order: ", cr_list)
    robot.endRequest(res, 'eve-team-reset')

  ## Helpers
  # if user is not in any list, put them in unassigned
  # if team is set, target that team always
  # team isn't set, for users not in unassigned, target there team
  # team isn't set, user in unassigned, target unassigned for meta
  # team isn't set, user in unassigned, target union of not unassigned for commands
  robot.getList = ->
    lists = robot.brain.get('enr-cr')

    if robot.options.team
      updateList = robot.options.team
    else
      requestorList = Object.keys(lists).filter((listName) =>
        lists[listName].some((name) ->
          name == robot.options.requestor))
    if !requestorList
      requestorList = 'unassigned'
      lists[requestorList] = robot.addArray(lists[requestorList], [robot.options.requestor])
      robot.setList(lists[requestorList])

    updateList == robot.options.team || requestorList
    lists[updateList].slice(0) # this clones the array, it was doing weird things

  robot.getListForCommand = ->
    null

  robot.getListForAdmin = ->
    null

  robot.setList = (list) ->
    lists = robot.brain.get('enr-cr')
    if robot.options.team
      updateList = robot.options.team
    else
      updateList = Object.keys(lists).filter((listName) =>
        lists[listName].some((name) ->
          name == robot.requestor))

    lists[updateList] = list
    robot.brain.set('enr-cr', lists)

  robot.seedDataStructure = ->
    data = robot.brain.get('enr-cr')
    if data == null
      robot.resetDataStructure()

  robot.resetDataStructure = ->
    data = {
      visness: ["josh.cohen", "dchang", "starr", "khoi", "brian.palladino", "daniel.herndon"],
      momo: ["jenpen", "joehunt", "cameron.ivey", "jackburum", "siva", "justdroo", "hugh.gardiner"],
      unassigned: []
    }
    robot.brain.set('enr-cr', data)
