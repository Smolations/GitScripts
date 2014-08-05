
function gh_git {
    local cmd="$@"

    git $@ &> "$GITHUG_LOG_FILE"
    echo '-------------------------------------------' &> "$GITHUG_LOG_FILE"
}
