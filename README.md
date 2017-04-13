# ENR Code Review Bot

Usage: type a command into any channel that the Excella Hobot bot has been added to

## Pick Reviewers ##

`enr-cr -n <number_of_random_reviewers> -i <list_of_ignored_users> -a <list_of_additional_reviewers>`

All options are optional, list of ignored users not yet implemented

**Users must be..**
1. in the current CR list
2. their names must be spelled right
3. Either have the prefix or not.

## View Current Order ##

`enr-cr-order`

just displays the current order

## Add a User ##

`enr-cr-add <user_names>`

Adds users to the end of the CR list.

**Users must be..**
1. Separated by a space
2. Spelled right
3. Either have the prefix or not.

**Note: There is no checking if a username is valid**

## Remove a User ##

`enr-cr-remove <user_names>`

Removes users from the CR list.

**Users must be..**
1. Separated by a space
2. Spelled right
3. Either have the prefix or not.
4. Currently in the list

## Set the Order ##

`enr-cr-set <user_names>`

Wipes the old cr list and sets it too the list of usernames, in that order

**Users must be..**
1. Separated by a space
2. Spelled right
3. Either have the prefix or not.

**Note: There is no checking if a username is valid**

