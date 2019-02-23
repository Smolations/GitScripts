oneTimeSetUp() {
  echo 'oneTimeSetUp'
}

oneTimeTearDown() {
  echo 'oneTimeTearDown'
}

setUp() {
  echo 'setUp'
}

tearDown() {
  echo 'tearDown'
}

test__gh_bad_usage() {
  echo 'running test'
  assertEquals 1 1
}

# test__gh_bad_usage() {
#   assertEquals 1 1
# }

# test__gh_bad_usage() {
#   assertEquals 1 1
# }


source "${runner_cmd}"
