oneTimeSetUp() {
  gitDir="${SHUNIT_TMPDIR}/gitDir"
  nonGitDir="${SHUNIT_TMPDIR}/nonGitDir"

  mkdir "${nonGitDir}"
  mkdir "${gitDir}"
  goto "$gitDir"
  git init > /dev/null
  goback
}

# oneTimeTearDown() {
#   # echo 'destroy dirs'
#   :
# }

# setUp() {
#   :
# }

# tearDown() {
#   :
# }


it_can_identify_a_repo_in_pwd() {
  goto "${gitDir}"
  gh_is_repo
  isRepo=$?
  goback
  assertEquals 0 $isRepo
}

it_can_identify_a_repo_with_given_path() {
  gh_is_repo "${gitDir}"
  isRepo=$?
  assertEquals 0 $isRepo
}

it_can_identify_a_non_repo_in_pwd() {
  goto "${nonGitDir}"
  gh_is_repo
  isRepo=$?
  goback
  assertEquals 1 $isRepo
}

it_can_identify_a_non_repo_with_given_path() {
  gh_is_repo "${nonGitDir}"
  isRepo=$?
  assertEquals 1 $isRepo
}

it_will_error_with_bad_path() {
  gh_is_repo "/a/b/c"
  isRepo=$?
  assertEquals 2 $isRepo
}


source "${runner_cmd}"



# `assertEquals [message] expected actual`
# `assertNotEquals [message] unexpected actual`
# `assertSame [message] expected actual`
# `assertNotSame [message] unexpected actual`
# `assertContains [message] container content`
# `assertNotContains [message] container content`
# `assertNull [message] value`
# `assertNotNull [message] value`
# `assertTrue [message] condition`
# `assertFalse [message] condition`

# `fail [message]`
# `failNotEquals [message] unexpected actual`
# `failSame [message] expected actual`
# `failNotSame [message] expected actual`
# `failFound [message] content`
# `failNotFound [message] content`

# Just to clarify, failures __do not__ test the various arguments against one
# another. Failures simply fail, optionally with a message, and that is all they
# do. If you need to test arguments against one another, use asserts.

# If all failures do is fail, why might one use them? There are times when you may
# have some very complicated logic that you need to test, and the simple asserts
# provided are simply not adequate. You can do your own validation of the code,
# use an `assertTrue ${SHUNIT_TRUE}` if your own tests succeeded, and use a
# failure to record a failure.
