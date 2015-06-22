## /*
#   @usage commit [-a] [<message>]
#   @usage commit [-A] [<message>]
#
#   @description
#   Commits already-staged work to a branch with a few extra benefits. The branch name
#   is prepended to the commit message so that all commits are easily associated with
#   their branch. The commit summary message is also automatically suppressed.
#
#   Non-staged work can be staged via the available options, which are described below.
#   description@
#
#   @options
#   -a  Automatically stage modified and deleted files before committing.
#   -A  Automatically stage ALL tracked/untracked files before committing.
#   options@
#
#   @notes
#   - If there are untracked files in the working tree and the user passes the -a
#   option, he/she will be prompted to add the untracked files as well.
#   notes@
#
#   @examples
#   $ commit -A "I know I added some untracked files, so I'll pass the right option"
#   examples@
#
#   @dependencies
#   functions/0100.bad_usage.sh
#   functions/5000.branch_exists.sh
#   functions/5000.is_branch_protected.sh
#   functions/5000.parse_git_branch.sh
#   functions/5000.parse_git_status.sh
#   functions/5000.set_remote.sh
#   dependencies@
#
#   @file commit.sh
## */

function commit {
    # parse arguments
    if [ "$1" == "-a" ] || [ "$1" == "-A" ];then
        flag=$1
        shift
    fi

    msg="$@"

    # conditions that should cause the script to halt immediately:
    # make sure SOMETHING is staged if user doesn't specify flag
    if ! gh_parse_git_status staged && [ ! $flag ]; then
        # echo
        echo "${E}  You haven't staged any changes to commit! Aborting...  ${X}"
        return 1
    fi

    startingBranch=$( gh_parse_git_branch )
    if [ -z "$startingBranch" ]; then
        echo "${E}  Unable to determine current branch.  ${X}"
        return 2
    fi


    # echo
    # echo "  Committing changes to branch: ${BN}\`${startingBranch}\`${X}"


    # check to see if user wants to add all modified/deleted files
    if [ $flag ]; then
        case $flag in
            "-a")
                if gh_parse_git_status untracked; then
                    # echo
                    __yes_no --default=n "Would you like to add untracked files as well"
                    if [ $_yes ]; then
                        # echo
                        # echo
                        # echo "Adding all modified and untracked files..."
                        # echo ${O}${H2HL}
                        # echo "$ git add -A"
                        gh_show_cmd git add --all .
                        gitAddResult=$?
                        if [ $gitAddResult != 0 ]; then
                            echo
                            echo "${W} WARNING: ${X} The command to add ALL tracked and untracked files failed (see"
                            echo "above). It is unlikely that your desired outcome will result from this commit."

                            __yes_no --default=n 'Do you still want to continue with the commit'
                            if [ $_no ]; then
                                echo
                                echo "That's probably for the best. Aborting..."
                                return 1
                            fi
                        fi
                    fi
                fi
            ;;

            "-A")
                flag=
                # echo
                # echo
                # echo "Adding all modified and untracked files..."
                # echo ${O}${H2HL}
                # echo "$ git add -A"
                gh_show_cmd git add --all .
                gitAddResult=$?
                # echo ${O}${H2HL}${X}
                if [ $gitAddResult -gt 0 ]; then
                    echo
                    echo "${W} WARNING: ${X} The command to add ALL tracked and untracked files failed (see"
                    echo "above). It is unlikely that your desired outcome will result from this commit."

                    __yes_no --default=n 'Do you still want to continue with the commit'
                    if [ $_no ]; then
                        echo
                        echo "That's probably for the best. Aborting..."
                        return 1
                    fi
                fi
            ;;

            *)
                gh_bad_usage commit
                return 4
                ;;
        esac
    fi


    # echo
    # echo
    # echo "Committing and displaying branch changes..."
    # echo ${O}${H2HL}
    # echo "$ git commit -q -m \"(${startingBranch}) $msg\" $flag"

    # if user supplied a message, commit it. otherwise, pop message in the $EDITOR
    if [ -z "$msg" ]; then
        gh_show_cmd git commit $flag -q

    else
        # gh_show_cmd git commit $flag -q -m "(${startingBranch}) $msg"
        gh_show_cmd git commit $flag -q -m "$msg"
    fi

    # echo ${O}
    # echo
    # echo "$ git diff-tree --stat HEAD"
    gh_show_cmd git diff-tree --stat HEAD
    # echo ${O}${H2HL}${X}
    # echo
    # echo
    # echo "Checking status..."
    # echo ${O}${H2HL}
    # echo "$ git status"
    gh_show_cmd git status
    # echo ${O}${H2HL}${X}
    # echo

    # wrap up...
    # if [ $isAdmin ]; then
    #     "${gitscripts_path}"push.sh --admin "$startingBranch"
    # else
    #     "${gitscripts_path}"push.sh "$startingBranch"
    # fi
}
