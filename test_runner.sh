#!/bin/bash

runner_path="$(pwd)/tmp/shunit2"
runner_cmd="${runner_path}/shunit2"
tests_path="$(pwd)/tests"


if [ ! -f "${runner_cmd}" ]; then
  echo "ERROR: Run tests from root of project!";
  exit
fi


source ./SOURCEME


getTests() {
  local path="$1"
  local testFile
  local filePath

  for testFile in "${path}/"*; do
    if [ -d "$testFile" ]; then
      getTests "$testFile"
    elif [ -e "$testFile" ]; then
      echo "$testFile"
    fi
  done
}


export runner_cmd

# maybe messes up if spaces in path? meh.
for tst in $(getTests "$tests_path"); do
  "$tst"
done
