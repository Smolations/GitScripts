function gh_show_cmd {
    echo "${O}$ ${@}${X}"

    # now execute it
    $@
}
