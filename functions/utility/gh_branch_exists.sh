## /* @function
#   @usage gh_branch_exists <branch_name>
#
#   @output false
#
#   @description
#   Determine if the given branch exists either locally or remotely. If it exists locally,
#   skip checking for the remote branch.
#   description@
#
#   @notes
#   - Since this function does not echo anything to be captured, it is most useful if
#   used directly in conditional statements. See example below.
#   notes@
#
#   @examples
#   # ...
#
#   if gh_branch_exists master; then
#       echo "Branch 'master' exists!"
#   fi
#
#   #...
#   examples@
#
#   @dependencies
#   egrep
#   gh_log
#   dependencies@
#
#   @file functions/utility/gh_branch_exists.sh
## */

function gh_branch_exists {
  if [ -z "$1" ]; then
    gh_log "gh_branch_exists: First parameter must be branch name."
    return 1
  fi

  local locally=$( git branch | egrep "^[* ]*${1}$" )

  if [ -n "$locally" ]; then
    return 0

  else
    local remotely=$( git branch -r | egrep "$1" )

    if [ -n "$remotely" ]; then
      return 0
    fi
  fi

  return 1
}
