
function pe_git {
    local cmd="$@"

    git $@ &> "$ge_log_path"
}
