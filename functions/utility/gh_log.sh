## /* @function
#   @usage gh_log <data>
#
#   @output file
#
#   @description
#   A custom logger for GitScripts. Usually failure messages that aren't useful to the user, but may be to
#   a developer will be put here as opposed to echoed to standard output.
#   description@
#
#   @notes
#   - Appends to log file only if a parameter is given and log file exists.
#   notes@
#
#   @examples
#   1) gh_log "starting my script..."
#   2) if [ $myage -lt 40 ]; then gh_log "You've still got time..."; fi
#   examples@
#
#   @file functions/utility/gh_log.sh
## */

function gh_log {
  # check for global var which turns logging on
  if [ $GITHUG_LOGGING_ON == true ]; then
    if _.isStdin; then
      cat - | _.log --file="$GITHUG_LOG_FILE"
    else
      _.log --file="$GITHUG_LOG_FILE" "$@"
    fi
  fi
}
