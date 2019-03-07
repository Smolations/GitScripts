

function gh_parse_usage {
  local file="${GITHUG_PATH}/functions/core/${1}.sh"

  if [[ -f "$file" ]]; then
    while IFS='' read -r line; do
      echo "usage:  ${line//*@usage /}"
    done < <( egrep '@usage' "$file" )
  fi
}
