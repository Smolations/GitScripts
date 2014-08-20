#!/bin/bash
## /*
#   @usage clean-branches [--base=<branch-name>]
#
#   @description
#   This script iterates through your local branches and prompts you to delete
#   branches that are fully merged into master.
#   description@
#
#   @options
#   --base=<branch-name>    By default, the base branch for merged branches is
#                           master. It can be changed using this option.
#   options@
#
#   @notes
#   - You will end on the same branch you started out on.
#   - To see which branches are already merged into the branch you’re on, you
#     can run git branch --merged.
#   - To see all the branches that contain work you haven’t yet merged in, you
#     can run git branch --no-merged.
#   notes@
#
#   @dependencies
#   *delete.sh
#   functions/5000.parse_git_branch.sh
#   dependencies@
#
#   @file clean-branches.sh
## */

function branch-cleanup {
    # parse args
    __in_args base "$@" && target="$_arg_val"

    # target is the branch which, if it contains one of the user's local
    # branches, will determine if the user will be prompted to delete
    [ -z "$target" ] && target="master"

    # to show current branch in output
    cb=$( gh_parse_git_branch )


    # start it up
    # echo "  Clean-Branches will iterate through your local branches and prompt you to  "
    # echo "  delete branches that have already been merged into ${BN}\`${target}\`${X}.  "
    echo

    # get target branch hash for display/comparison purposes
    targetHash=$( git show --oneline "$target" )
    targetHash="${targetHash:0:7}"
    echo "${BN}\`${target}\`${X} hash: ${STYLE_BRIGHT}${COL_MAGENTA}${targetHash}"${X}
    echo

    # send list of all local branches to temp file
    tmp="${gitscripts_temp_path}vbranch"
    git branch -v | awk '{gsub(/^\* /, "");print;}' > $tmp

    # run loop. reads from temp file.
    declare -a branchNames
    declare -a branchHashes
    while read branch; do
        pieces=( $branch )
        if grep -q '' <<< git branch --contains "${pieces[1]}" | egrep -q "${target}"; then

            [ "$targetHash" = "${pieces[1]}" ] && {
                op="${STYLE_BRIGHT}==="
                bHash="${STYLE_BRIGHT}${pieces[1]}"
            } || {
                op="\\__"
                bHash="${pieces[1]}"
            }

            [ "${pieces[0]}" = "$cb" ] && star="*" || star=" "

            branchNames[${#branchNames[@]}]="${pieces[0]}"
            branchHashes[${#branchHashes[@]}]="${pieces[1]}"
            echo "${STYLE_BRIGHT}${COL_MAGENTA}${targetHash}${X} ${COL_YELLOW}${op}${X} ${COL_MAGENTA}${bHash}${X} ::${B}${star}${pieces[0]}"${X}
        fi
    done <"$tmp"

    # temp file no longer necessary
    rm "$tmp"

    echo
    __yes_no --default=n 'Would you like to begin deleting branches'
    if [ $_no ]; then
        echo "  Right on. Exiting..."
        return 0
    fi

    # let's get this party started...
    for (( i = 0; i < ${#branchNames[@]}; i++ )); do
        # "${gitscripts_path}"delete.sh $aFlag "${branchNames[$i]}"
        delete $aFlag "${branchNames[$i]}"
    done
}
