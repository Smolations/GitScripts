
function gh_git {
    local cmd="$@"

    git $@ &> "$gh_log_path"
}
