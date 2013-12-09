#! /bin/sh
. ./test/helper.sh

testExecNoArguments()
{
	./testflight_post 2>/dev/null
	assertEquals "did not exit with 1" 1 $?
}

testExecNoCommand()
{
	./testflight_post "$test_ruby_version" 2>/dev/null
	assertEquals "did not exit with 1" 1 $?
}

# run shunit2
SHUNIT_PARENT=$0 . $SHUNIT2