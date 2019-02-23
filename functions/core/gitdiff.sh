## /*
#   @usage gitdiff [-am] [base-branch]
#
#   @description
#   This script is used to get a quick look at all the files that have been added,
#   modified, and/or deleted in the current branch's latest commit and either a
#   specified branch (the first parameter) or the master branch (default; from remote).
#   You can optionally specify that you only want to view currently modified files
#   or commits AND modified files.
#   description@
#
#   @options
#   -a      Show the diff between the base-branch and HEAD, including any currently
#           modified files in the working tree (i.e. changed files between remote
#           branch and current state of your working tree).
#   -l      Only show a diff of HEAD with any currently modified/deleted/renamed
#           files in the working tree (i.e. changed files since immediately previous commit).
#   options@
#
#   @notes
#   - If your project does not have a master branch, you will need to pass the first
#   parameter for each use.
#   - You may specify a hash as an argument instead of a base-branch name.
#   notes@
#
#   @examples
#   $ gitdiff stage      # Shows diff between the stage branch and HEAD
#   $ gitdiff 3bdaf1     # Shows diff between commit 3bdaf1 and HEAD
#   $ gitdiff -m         # Shows diff between HEAD and any dirty files in the working tree.
#   examples@
#
#   @dependencies
#   functions/1000.set_remote.sh
#   functions/5000.branch_exists.sh
#   dependencies@
#
#   @file gitdiff.sh
## */

function gitdiff {
    gh_set_remote

    branch="master"
    [ -n "$_remote" ] && branch="${_remote}/master"

    if [ -n "$1" ]; then
        case "$1" in
            -l)
                showModified=true
                [ -n "$2" ] && branch="$2";;

            -a)
                showAll=true
                [ -n "$2" ] && branch="$2";;

            *)
                branch=$1;;
        esac
    fi

    # make sure branch exists
    if ! gh_branch_exists "$branch"; then
        # maybe the user passed a hash instead of a branch?
        if ! git log -1 --oneline "$branch" &>/dev/null; then
            echo ${E}"  Branch (or hash) \`$branch\` does not exist! Aborting...  "${X}
            exit 1
        fi
    fi

    # get 7 digit shortened hash for each commit
    hashFrom=$( git rev-parse --short $branch )
    hashTo=$( git rev-parse --short HEAD )
    hashes="${hashFrom}..${hashTo}"
    [ "$hashFrom" == "$hashTo" ] && hashesSame=true || hashesSame=

    # Based on options passed to this script, figure out what the diff hashes should be
    if [ $showModified ]; then
        hashes="$hashTo"
    elif [ $showAll ]; then
        hashes="$hashFrom"
    fi

    # tell us if we have two hashes for the specs
    grep -q '\.' <<< "$hashes" && hasRange=true || hasRange=

    if [ ! $hashesSame ] && [ ! $showModified ]; then
        gh_show_cmd git --no-pager log --oneline -30 ${hashFrom}..${hashTo}

        echo
    fi

    gh_show_cmd git diff --name-status $hashes

    ## seems theres a way to parse status and type of change for custom formatting
    # if [ "$WINDOWS" == "true" ]; then
    # else
    #     while read STATUS ADDR; do
    #         echo "  # $ADDR  ($STATUS)"
    #     done  < <(git diff --name-status ${hashes})
    # fi


    # only need to ask to do a diff if there ARE differences.
    if [ -n "$( git diff --name-status $hashes )" ]; then
        echo
        _.yesNo --default=n "See the diff"
        if [ $_yes ]; then
            # look for a difftool first, asking user
            difftoolCmd=$( git config --global --list | egrep 'difftool\.[^.]+\.cmd' )

            if [ -n "$difftoolCmd" ]; then
                _.yesNo --default=y "You have a difftool configured. Use it to view diff"
                echo
                if [ $_yes ]; then
                    gh_show_cmd git difftool $hashes
                else
                    gh_show_cmd git diff -w $hashes
                fi

            else
                gh_show_cmd git diff -w $hashes
            fi
        fi
    fi
}
