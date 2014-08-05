## /* @function
#   @usage ge_log <data>
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
#   1) __gslog "starting my script..."
#   2) if [ $myage -lt 40 ]; then __gslog "You've still got time..."; fi
#   examples@
#
#   @file functions/utility/gs_log.sh
## */
function gh_log {
    # check for global var which turns logging on

    if __is_stdin; then
        cat - | __log --file="$ge_log_path"
    else
        __log "$@"
    fi
}
