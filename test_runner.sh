#!/bin/bash

tests_path="$(pwd)/tests"
runner_path="$(pwd)/lib/shunit2"
export runner_cmd="${runner_path}/shunit2"


if [ ! -f "${runner_cmd}" ]; then
  echo "ERROR: Could not find shunit at ${runner_cmd}";
  exit
fi


source ./SOURCEME


goto() {
  pushd "$@" > /dev/null
}

goback() {
  popd > /dev/null
}

getTestNameFromFile() {
  local input="$@"
  local baseName="$(basename "${input}")"
  echo "${baseName%%\.sh}"
}

header() {
  echo
  echo " /^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^/"
  echo "/-------------------------------------------------------/"
  echo "| Test:  ${@}"
  echo "-------------------------------------------------------/"
}


core=(
)

utility=(
  'gh_is_repo'
  'gh_bad_usage'
)

export -f goto goback


# maybe messes up if spaces in path? meh.
for tst in ${utility[@]} ${core[@]}; do
  test_file="${tests_path}/utility/${tst}.sh"

  if [ -e "$test_file" ]; then
    header "$(getTestNameFromFile "${test_file}")"
    "$test_file"
  else
    echo "ERROR: Cannot find test file: ${test_file}"
  fi
done
