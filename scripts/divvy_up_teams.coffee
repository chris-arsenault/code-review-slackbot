module.exports = (robot) ->
  robot.hear /^divvy-up-teams([ ])+([a-z. 0-9,_,&,!,@,#,\$,%,\^,\*,\(,\)]*)?([\-@_a-z. 0-9]*)*$/i,  (res) ->
    console.log("divvy-up-teams called")
    robot.setTeamMembers()
    teams = robot.getTeams()
    items = robot.getItems(res)
    assignments = robot.assign(items, teams)
    res.send "Assignments \n" + robot.printAssignments(assignments)
    robot.printAssignments(assignments)

  robot.getTeams = () =>
    teamsObject = robot.brain.get('teamMembers')
    Object.keys(teamsObject)
