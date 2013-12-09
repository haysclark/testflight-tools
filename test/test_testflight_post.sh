#! /bin/sh
# file: examples/equality_test.sh

oneTimeSetUp()
{
  cd ..
}

tearDown()
{
  rm ./results.txt
}

testScriptShouldOutputExpectedRequirements()
{	
	./testflight_post > ./results.txt
	diff ./test/expected_default.txt ./results.txt
	assertTrue 'Expected output differs.' $?
}

testScriptShouldOutputExpectedVersion()
{
	./testflight_post -v > ./results.txt
	firstline=`head -1 ./results.txt`
	assertEquals 'testflight_post version 1.1' "${firstline}"
}

# load shunit2
. /usr/local/bin/shunit2