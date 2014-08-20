#!/bin/bash
## /*
#   @usage pull [branch-name] [-q, --quiet]
#
#   @description
#   This is a quick script that pulls in changes from the current branch's remote
#   tracking branch if it exists. User can also specify another branch to pull
#   in changes from. Pull branch is verified to exist on the remote first. If
#   it doesn't, the script is aborted.
#   description@
#
#   @dependencies
#   functions/5000.branch_exists.sh
#   functions/5000.parse_git_branch.sh
#   functions/5000.set_remote.sh
#   dependencies@
#
#   @file pull.sh
## */

function pull {
    # parse params
    __in_args quiet "$@" && isQuiet=true
    __in_args q "${_args_clipped[@]}" && isQuiet=true

    branch="${_args_clipped[@]}"

    cb=$( gh_parse_git_branch )
    pullBranch="$cb"

    __set_remote

    if [ ! $_remote ]; then
        echo "${E}  There is no remote to pull in changes from! Aborting...  ${X}"
        return 1
    fi


    # if user specified a branch, fetch and pull it in (if it exists).
    if [ -n "$branch" ]; then
        gh_branch_exists_remote "$branch" && { pullBranch="$branch"; } || {
            echo "${E}  The branch \`$branch\` does not exist on the remote! Aborting...  ${X}"
            return 2
        }
    fi

    # give the user an opportunity to abort if no -q or --quiet flag passed
    # if [ ! $isQuiet ]; then
    #     echo ${Q}"Are you sure you want to ${A}pull${Q} changes from ${STYLE_NEWBRANCH}\`${_remote}/${pullBranch}\`${Q} into ${STYLE_OLDBRANCH}\`${cb}\`${Q}? (y) n"
    #     read yn
    #     echo
    #     if [ -n "$yn" ] && [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
    #         echo "Better safe than sorry! Aborting..."
    #         exit 0
    #     fi
    # fi

    # echo ${H1}${H1HL}
    # echo "  Pulling in changes from ${H1B}\`${_remote}/${pullBranch}\`${H1}  "
    # echo ${H1HL}${X}
    # echo
    # echo
    # echo "${A}Fetching${X} updated changes from ${COL_GREEN}${_remote}${X} and ${A}pulling${X} them into ${B}\`${cb}\`${X}..."
    # echo ${O}${H2HL}
    # echo "$ git fetch --all --prune"
    gh_show_cmd git fetch --all --prune
    # echo
    echo
    # echo ${O}"$ git pull ${_remote} ${pullBranch}"
    gh_show_cmd git pull "$_remote" "$pullBranch"
}
