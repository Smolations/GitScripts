## /*
#   @usage prune <branch-name>
#
#   @description
#   This script is a wrapper for removing branches locally. Removing them locally requires a bit of
#   magic, which can be determined by observing the source code carefully. This obfuscation is
#   included to prevent team members without sufficient access from deleting important remote
#   branches.
#   description@
#
#   @dependencies
#   *checkout.sh
#   functions/0100.bad_usage.sh
#   functions/5000.branch_exists_local.sh
#   functions/5000.branch_exists_remote.sh
#   functions/5000.parse_git_branch.sh
#   dependencies@
#
#   @file delete.sh
## */

function prune {
    # parse arguments

    forceDelete=false
    deletePhrase="Deleting branch"
    deleteBranch="$@"
    cb=$(gh_parse_git_branch)
    declare -a branches



    # make sure branch name was included
    if [ -z "$deleteBranch" ]; then
        # prune all!
        echo "No branch given. Evaluating ALL branches."

        while IFS= read line; do
            ! egrep -q '^\*' <<< "$line" && branches[${#branches[@]}]="${line#  }"
        done < <( git branch )

    else
        gh_branch_exists_local "$deleteBranch" && isLocal=true
        if [ ! $isLocal ]; then
            echo "${E}  The branch \`${deleteBranch}\` does not exist locally! Aborting...  ${X}"
            return 1
        fi

        branches=( $deleteBranch )

        # __set_remote && __branch_exists_remote "$deleteBranch" && isRemote=true
    fi


    for (( i = 0; i < ${#branches[@]}; i++ )); do
        curBranch="${branches[$i]}"

        if [ "$curBranch" != "master" ]; then
            echo -n "${BN}\`${curBranch}\`${X}"

            # check if on branch
            if [ "$cb" == "$curBranch" ]; then
                echo "  Branch currently checked out. Skipping."
                continue
            fi

            # prompt to delete branch
            __yes_no --default=n "Delete this branch"
            if [ $_yes ]; then

                # prompt for force delete if normal delete fails for some reason
                if ! gh_show_cmd git branch -d $curBranch; then

                    __yes_no --default=n "Normal delete failed. Force delete"
                    if [ $_yes ]; then
                        gh_show_cmd git branch -D $curBranch
                    fi

                fi

            fi
        fi
    done


    # if [ $isLocal ]; then

    #     #Determine if your local copy is behind remote
    #     if [ $isRemote ] && git branch -v --abbrev=7 | egrep -q "$deleteBranch.*\[behind\ [0-9]*\]"; then
    #         if [ $forceDelete == false ]; then
    #             echo ${W}"Your local copy of this \`${deleteBranch}\` is behind the remote."
    #             echo "Continue anyways? (y) n"${X}
    #             read yn
    #             if [ -n "$yn" ] && { [ "$yn" != "y" ] || [ "$yn" != "Y" ]; }; then
    #                 echo
    #                 echo "Aborting delete of ${B}\`${deleteBranch}\`"${X}
    #                 exit 1
    #             fi
    #         else
    #             if ! git branch -D $deleteBranch; then
    #                 echo ${E}"  Force delete failed! Exiting... "${X}
    #                 exit 1
    #             else
    #                 echo ${COL_GREEN}"Force delete succeeded!"${X}
    #                 echo
    #                 echo "Exiting..."
    #                 exit 0
    #             fi
    #         fi
    #     fi

    #     if ! git branch -d "$deleteBranch" > /dev/null; then

    #         if [ $forceDelete == false ]; then
    #             echo ${W}"Delete failed! Would you like to force-delete the branch?  y (n)"${X}
    #             read yn
    #             echo
    #             if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
    #                 if ! git branch -D $deleteBranch; then
    #                     echo ${E}"  Force delete failed! Exiting... "${X}
    #                     exit 1
    #                 else
    #                     echo ${COL_GREEN}"Force delete succeeded!"${X}
    #                     echo
    #                 fi
    #             elif [ ! $isAdmin ]; then
    #                 echo "Exiting..."
    #                 exit 0
    #             fi
    #         else
    #             if ! git branch -D $deleteBranch; then
    #                 echo ${E}"  Force delete failed! Exiting... "${X}
    #                 exit 1
    #             else
    #                 echo ${COL_GREEN}"Force delete succeeded!"${X}
    #                 echo
    #             fi
    #         fi

    #     else
    #         echo ${COL_GREEN}"Delete succeeded!"${X}
    #         echo
    #     fi

    # else
    #     [ ! $isAdmin ] && echo ${E}"  Branch does not exist locally. Skipping delete...  "${X}
    # fi

    # if [ $isAdmin ]; then
    #     if [ $isRemote ]; then
    #         echo
    #         echo ${Q}"Delete ${B}\`${_remote}/${deleteBranch}\`${Q}? y (n)"${X}
    #         read yn
    #         echo

    #         if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then

    #             if __is_branch_protected --all "$deleteBranch"; then
    #                 echo ${W}"WARNING: \`${deleteBranch}\` is a protected branch."
    #                 echo "Are you SURE you want to delete the remote copy? yes (n)${X}"${X}
    #                 read yn
    #                 if [ -z "$yn" ] || [ "$yn" != "yes" ]; then
    #                     echo "Aborting delete of remote branch..."
    #                     exit 1
    #                 fi
    #             fi

    #             echo
    #             echo "Deleting ${B}\`${_remote}/${deleteBranch}\`${X} ..."
    #             echo ${O}${H2HL}
    #             echo "$ git push ${remote} :${deleteBranch}"
    #             git push "$remote" :"$deleteBranch"
    #             echo ${H2HL}${X}
    #         else
    #             echo "Delete aborted. Exiting..."
    #             exit 1
    #         fi
    #     else
    #         echo "Branch \`${deleteBranch}\` is not on a remote. Now exiting..."
    #         exit 1
    #     fi
    # fi
}
