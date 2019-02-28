oneTimeSetUp() {
  cmdName=gh_bad_usage
}

oneTimeTearDown() {
  :
}

setUp() {
  :
}

tearDown() {
  :
}


it_errors_when_missing_argument() {
  ${cmdName} &> /dev/null
  assertEquals $? 1
}

# test__gh_bad_usage() {
#   assertEquals 1 1
# }

# test__gh_bad_usage() {
#   assertEquals 1 1
# }


source "${runner_cmd}"
