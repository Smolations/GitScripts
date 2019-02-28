## /* @function
#   @usage gh_is_repo <path>
#
#   @output false
#
#   @description
#   A quick check to see if the current working directory is in the path
#   of a git repository. A path can be specified to check a location
#   other than the current working directory.
#   description@
#
#   @notes
#   - Intended to be used in conditional statements.
#   notes@
#
#   @file functions/utility/gh_is_repo.sh
## */

function gh_is_repo {
  local path="${@:-$(pwd)}"
  local isRepo

  if [ -d "$path" ]; then
    [ -d "${path}/.git" ] || git -C "$path" rev-parse --git-dir > /dev/null 2>&1
    isRepo=$([ $? -eq 0 ] && echo 0 || echo 1)
  else
    isRepo=2
  fi

  return $isRepo
}
