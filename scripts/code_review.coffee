module.exports = (robot) ->

  robot.respond /enr-cr[\ ]?(\d*)?[\ ]?([@a-z\.\ ]*)?$/i, (res) ->


    count = 1
    if (res.match[1] != undefined)
      count = res.match[1]

    # no default
    if (res.match[2] != undefined)
      extra_requestor = res.match[2].split(' ').map((n) -> n.trim())

    list = robot.brain.get('enr-cr')

    # seed the list
    if list == null || list == []
      list = ["@chris.arsenault", "@josh.cohen", "@jenpen", "@joehunt", "@starr", "@cameron.ivery", "@khoi", "@jackburum", "@siva"]

    requestor = res.message.user.name

    reviewers = []
    #add extra reviewers and put them on the back if there are any
    if extra_requestor != undefined
      while extra_requestor.length != 0
        extra = extra_requestor.shift()

        # make sure the name is spelled good
        if list.indexOf(extra) != -1 || list.indexOf('@' + extra) != -1
          reviewers.push(extra)
          list.splice(list.indexOf(extra))
          list.push(extra)

    # get next count reviewers
    while count != 0
      # swap requestor
      if list[0] == requestor
        list[0] = list[1]
        list[1] = requestor

      # get the reviewer
      reviewers.push(list[0])

      # put reviewer on back
      list.push(list.shift())

      # next request
      count--

    response = "Assigned Reviewer: "
    for reviewer in reviewers
      response += "@#{reviewer}, "

    robot.brain.set('enr-cr', list)

  robot.respond /enr-cr-set ([@a-z\.\ ]*)+$/i, (res) ->
    names = res.match[1].split(' ')
    cr_list = []
    for name in names
      if !!name
        if name.indexOf('@') == -1
          name = '@' + name
        cr_list.push(name)

    robot.brain.set('enr-cr', cr_list)

    response = "New Order: "
    for l in cr_list
      response += (l + ", ")
    res.send response

  robot.respond /enr-cr-order/i, (res) ->
    cr_list = robot.brain.get('enr-cr')

    response = "Current Order: "
    for l in cr_list
      response += (l + ", ")
    res.send response

  robot.respond /enr-cr-add ([@a-z\.\ ]*)+$/i, (res) ->
    cr_list = robot.brain.get('enr-cr')
    names = res.match[1].split(' ')
    for name in names
      if !!name
        if name.indexOf('@') == -1
          name = '@' + name
        cr_list.push(name)

    robot.brain.set('enr-cr', cr_list)

    response = "New Order: "
    for l in cr_list
      response += (l + ", ")
    res.send response

  robot.respond /enr-cr-remove ([@a-z\.\ ]*)+$/i, (res) ->
    cr_list = robot.brain.get('enr-cr')
    names = res.match[1].split(' ')
    for name in names
      if !!name
        if name.indexOf('@') == -1
          name = '@' + name
        if cr_list.indexOf(name) != -1
          cr_list.splice(cr_list.indexOf(name))

    robot.brain.set('enr-cr', cr_list)

    response = "New Order: "
    for l in cr_list
      response += (l + ", ")
    res.send response
