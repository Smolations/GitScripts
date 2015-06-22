## /*
#   @usage branch [options] [search-string]
#
#   @description
#   This is a handy tool to filter local and/or remote branch names in your repository.
#   It leverages the __get_branch function to let the user choose a branch. For more
#   information on that part of the process, @see functions/5000.get_branch.sh.
#   description@
#
#   @options
#   -l, --local     Show only local branches.
#   -q, --quiet     Do not show the informational message containing search query.
#   -r, --remote    Show only remote branches.
#   options@
#
#   @notes
#   - Search string CANNOT begin with a hyphen!
#   - Passing both options above will result in showing ALL branches as expected.
#   notes@
#
#   @examples
#   1) branch --local part-of-bran
#      # filters local branches that match "part-of-bran"
#   2) branch -r
#      # shows ALL remote branches
#   examples@
#
#   @dependencies
#   *checkout.sh
#   functions/5000.get_branch.sh
#   dependencies@
#
#   @file branch.sh
## */

function branch {
    # send params through to __get_branch
    gh_get_branch $@

    # if no selection was made or no branch could be found, exit.
    if [ ! $_branch_selection ]; then
        echo "${E}  Unable to acquire a branch name. Aborting...  ${X}"
        return 1
    fi

    echo $X

    # prompt to checkout branch
    __yes_no --default=y "Would you like to checkout ${BN}\`${_branch_selection}\`${X}"

    [ $_yes ] && echo && checkout "$_branch_selection"
}
