module.exports = (robot) ->

# /enr-cr[\ ]?(\d*)?[\ ]?([@a-z\.\ ]*)?$/i
  robot.hear /eve-cr([ ])?([\-@a-z. 0-9]*)?$/i, (res) ->
    options = robot.startRequest(res, 'enr-cr')

    if !options
      return

    if options.error
      res.send robot.usageString()
      return

    list = robot.getList()

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
    options.ignored_reviewers.push(options.requestor)
    ignored_reviewers = robot.cleanNames(options.ignored_reviewers, list)
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

    robot.setList(list)
    res.send robot.printList("Assigned Reviewers: ", reviewers, true)
    console.log 'enr-cr ended'

  #### HELPERS ####

  robot.usageString = () ->
    "enr-cr -n <number_of_random_reviewers> -i <list_of_ignored_users> -a <list_of_additional_reviewers>"





