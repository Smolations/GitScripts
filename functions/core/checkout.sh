## /*
#   @usage checkout [branch-name]
#
#   @description
#   This script assists with checking out a branch in several ways. Firstly, if you
#   don't know the specific name of the branch for whatever reason, you can omit the
#   branch name as the first parameter to view a list of all branches, even branches
#   on the remote, if any. Secondly, You are automatically prompted to merge master into
#   the branch which you are checking out to keep it current. In addition, safeguards
#   are in place to prevent unnecessary processing if, for instance, you are already
#   on the branch you are trying to checkout or the branch doesn't exist locally,
#   remotely, or at all.
#   description@
#
#
#   @examples
#   1) checkout
#      # Will show a list of branches available for checkout.
#   2) checkout my-big-project-changes
#      # checks out my-big-project-changes and will attempt to merge master into it
#      # or rebase it onto master.
#   examples@
#
#   @dependencies
#   functions/0300.menu.sh
#   functions/5000.branch_exists_remote.sh
#   functions/5000.branch_exists_local.sh
#   functions/5000.parse_git_branch.sh
#   functions/5000.parse_git_status.sh
#   functions/5000.set_remote.sh
#   dependencies@
#
#   @file checkout.sh
## */

function checkout {
    local onremote= onlocal= patt branch

    # If no branch name is provided as the first parameter, a list of branches from the
    # user's local repository are shown, giving them a choice of which to checkout. Users may
    # also view remote branches if desired.
    if [ -z "$1" ]; then
        echo "${W} WARNING: ${X} Checkout requires a branch name."
        echo

        if ! gh_get_branch -l; then
            echo
            echo "No branch chosen."
            return 1
        else
            checkout "$_branch_selection"
            return
        fi
    fi

    cb=$( gh_parse_git_branch )

    # set the branch that the script will be using
    patt="[^/]*\/"
    branch=${1/$patt/}

    if [ "$cb" == "$branch" ]; then
        echo "You are already on branch ${BN}\`${branch}\`${X}."
        return
    fi


    # Configure the remote if one or more exists
    __set_remote

    # Get up-to-date info from the remote, if any
    if [ $_remote ]; then
        # echo
        # echo "This tells your local git about all changes on ${COL_GREEN}${_remote}${COL_NORM}..."
        # echo ${O}${H2HL}
        gh_show_cmd git fetch --all --prune
        # echo

        gh_branch_exists_remote "$branch" && onremote=true
    fi

    gh_branch_exists_local "$branch" && onlocal=true

    # its possible that only part of the branch name was specified
    if [ ! $onlocal ] && [ ! $onremote ]; then
        branch "$branch"
        return $?
    fi


    # echo
    echo "Checking out branch:  ${BN}\`${branch}\`${X}"
    # echo

    # check for "dirty" working directory and provide options if that is the case.
    if ! __parse_git_status clean; then
        echo
        echo "${W} WARNING: ${X} You appear to have uncommitted changes."
        echo
        declare -a choices
        choices[0]="${A}Commit${X} changes and continue with checkout"
        choices[1]="${A}Stash${X} Changes and continue with checkout"
        choices[2]="${A}Reset${X} all changes to tracked files (ignores untracked files), and continue with checkout"
        choices[3]="${A}Reset${X} & ${A}Clean${X} all files, and continue with checkout"
        choices[4]="I know what I'm doing, continue with checkout"${X}

        if __menu "${choices[@]}"; then
            echo ${X}
            case $_menu_sel_index in
                # Commit changes and continue
                1)
                    __short_ans "Please enter a commit message:"
                    [ -z "$_ans" ] && _ans="[git-hug commit] Commit message omitted."
                    commit -a "$_ans"
                ;;

                # Stash changes and continue
                2)
                    # echo "This ${A}stashes${X} any local changes you might have made and forgot to commit."
                    # echo "To access these changes at a later time you can choose between the following:"
                    # echo "- reapply these changes to a ${STYLE_BRIGHT}new${STYLE_NORM} branch using: ${A}git stash branch <branch_name>"${X}
                    # echo "- OR apply these changes to any branch you are currently on using: ${A}git stash apply"${X}
                    gh_show_cmd git stash
                    # echo
                ;;

                # Reset changes to tracked files and continue
                3)
                    # echo "This attempts to ${A}reset${X} your current branch to it's last stable hash, usually HEAD."
                    # echo "If you have made changes to untracked files, they will NOT be affected."
                    # echo ${O}${H2HL}
                    gh_show_cmd git reset --hard
                    # echo
                ;;

                # Reset, clean, and continue
                4)
                    echo "${W} WARNING: ${X} Here's what will happen during the clean:"
                    echo
                    gh_show_cmd git clean --dry-run
                    echo

                    __yes_no --default=n "Continue with git clean and checkout"

                    if [ $_no ]; then
                        return
                    fi

                    # echo "This attempts to ${A}reset${X} your current branch to the last stable commit (HEAD)"
                    # echo "and attempts to ${A}clean${X} your current branch of all untracked files."
                    gh_show_cmd git reset --hard
                    # echo
                    gh_show_cmd git clean -f
                    # echo
                ;;

                # Ignore warning and continue
                5)
                    # echo "Continuing..."
                    # echo
                    :
                ;;

                # User aborted
                *)
                    # echo "Exiting..."
                    return
                ;;
            esac

        else
            # echo
            # echo ${E}"  Unable to determine branch to checkout. Aborting...  "${X}
            return 1
        fi

    else
        # echo "Working directory is ${O}clean${X}."
        # echo
        :
    fi
    # END - uncommitted changes/untracked files


    # Checkout the chosen branch if possible.
    gh_show_cmd git checkout "$branch"
    # echo "This checks out the ${B}\`${branch}\`${X} branch."
    # echo ${O}${H2HL}${X}
    # if [ $onlocal ]; then
    #     gh_show_cmd git checkout "$branch"
    # else
    #     new "$branch" from "${_remote}/$branch" --no-questions
    # fi


    # Get updated changes from the remote (there should rarely be any for personal branches)
    # if [ $onremote ]; then
    #     echo
    #     echo "$ git pull ${_remote} ${branch}"
    #     git pull "$_remote" "$branch"
    #     echo ${O}${H2HL}${X}
    # fi


    # MERGE master into branch to keep it up to date
    # echo
    # echo
    # if [ "$branch" != "master" ]; then
    #     if [ $onremote ]; then
    #         __merge_master

    #     # ...otherwise rebase this branch's changes onto master ("cleaner" option)
    #     else
    #         echo ${Q}"${A}Rebase${Q} branch ${B}\`${branch}\`${Q} onto \`${B}master${Q}? (y) n"${X}
    #         read decision

    #         if [ -z "$decision" ] || [ "$decision" = "y" ] || [ "$decision" = "y" ]; then
    #             echo
    #             echo "${A}Rebasing${X} ${B}\`${branch}\`${X} onto ${B}\`${remote}/master\`${X} ..."
    #             echo ${O}${H2HL}
    #             echo "$ git rebase ${remote}/master"
    #             git rebase "${remote}/master"
    #             echo ${O}
    #             echo
    #         else
    #             echo
    #             echo ${O}${H2HL}
    #             __merge_master
    #         fi
    #     fi
    # fi
}
