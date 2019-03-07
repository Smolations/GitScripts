## /* @function
#   @usage gh_bad_usage <command_name>
#
#   @output true
#
#   @description
#   Makes error messages a little easier to read. They are prefixed with the command name,
#   include coloring, and direct the user to use the GS Manual. However, if the user wishes
#   to use this function with a command that has no gsman entry, option -o can be used
#   and the reference to the gsman entry will be omitted.
#   description@
#
#   @notes
#   - A message cannot be given without a command name.
#   notes@
#
#   @examples
#   1) gh_bad_usage checkout "That branch name does not exist."
#       >> checkout: That branch name does not exist. Use "gsman checkout" for usage instructions.
#   2) gh_bad_usage -o merge
#       >> merge: Invalid usage.
#   3) gh_bad_usage
#       >> Error: Invalid usage. Use "gsman <command>" for usage instructions.
#   examples@
#
#   @dependencies
#   gh_parse_usage
#   dependencies@
#
#   @returns
#   0 - successful execution
#   1 - first argument is missing
#   returns@
#
#   @file functions/utility/gh_bad_usage.sh
## */

function gh_bad_usage {
  local hcolor=${COL_MAGENTA}

  if [[ $# != 1 ]]; then
    echo "gh_bad_usage: Must provide command name." 1>&2
    return 1
  fi

  local usage=$( gh_parse_usage $1 )

  if [ -n "$usage" ]; then
    echo "Invalid usage for ${hcolor}${1}${X}. Correct usage below:"
    echo $usage

  else
    echo "Invalid usage for ${hcolor}${1}${X}, but could not find usage details in file comment."
    return 2
  fi
}
