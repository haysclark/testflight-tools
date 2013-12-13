#! /bin/sh
. ./test/helper.sh

oneTimeTearDown()
{
  rm ./results.txt
}

testScriptShouldOutputExpectedRequirements()
{	
	EXPECTED='Expected output differs.'
	./testflight_post > ./results.txt
	diff ./test/expected_default.txt ./results.txt
	assertTrue "${EXPECTED}" $?
}

testScriptShouldWarnIfReleaseNotesIsMissing()
{
	EXPECTED="release notes are required and must be supplied or set in the script"
	./testflight_post test/fake.ipa > ./results.txt
	firstline=`head -1 ./results.txt`
	assertEquals "${EXPECTED}" "${firstline}"
}

testScriptShouldWarnIfApiTokenIsMissing()
{
	EXPECTED="api_token is not supplied and is file path is required"
	./testflight_post test/fake.ipa "fake notes" > ./results.txt
	firstline=`head -1 ./results.txt`
	assertEquals "${EXPECTED}" "${firstline}"
}

testScriptShouldWarnIfTeamTokenIsMissings()
{
	EXPECTED="team_token is not supplied and is file path is required"
	./testflight_post -u "fakeUploadToken" test/fake.ipa "fake notes" > ./results.txt
	firstline=`head -1 ./results.txt`
	assertEquals "${EXPECTED}" "${firstline}"
}

testScriptShouldAttemptUploadIfAllNeededArgumentAreUsed()
{
	EXPECTED="Invalid team token (did you get it from https://testflightapp.com/dashboard/team/edit/?)"
	./testflight_post -u "fakeUploadToken" -t "fakeTeamToken" test/fake.ipa "fake notes" > ./results.txt
	firstline=`head -1 ./results.txt`
	assertEquals "${EXPECTED}" "${firstline}"
}

testScriptShouldDefaultToCurl()
{
	EXPECTED="curl"
	./testflight_post -d -u "fakeUploadToken" -t "fakeTeamToken" test/fake.ipa "fake notes" | grep -q "${EXPECTED}"
	assertTrue "expecting correct url" "$?"
}

testCFlagShouldSetCurlAlternativeCommand()
{
	EXPECTED="furl"
	./testflight_post -d -c "${EXPECTED}" -u "fakeUploadToken" -t "fakeTeamToken" test/fake.ipa "fake notes" | grep -q "${EXPECTED}"
	assertTrue "expecting correct url" "$?"
}

testWFlagShouldSetUrl()
{
	EXPECTED="http::/foo/"
	./testflight_post -d -w "${EXPECTED}" -u "fakeUploadToken" -t "fakeTeamToken" test/fake.ipa "fake notes" | grep -q "curl "${EXPECTED}""
	assertTrue "expecting correct url" "$?"
}

testScriptShouldOutputExpectedVersion()
{
	EXPECTED="testflight_post version 1.1"
	./testflight_post -v > ./results.txt
	firstline=`head -1 ./results.txt`
	assertEquals "${EXPECTED}" "${firstline}"
}

testDFlagShouldPerformDryRun()
{
	EXPECTED="curl http://testflightapp.com/api/builds.json -F file=@test/fake.ipa -F api_token=fakeUploadToken -F team_token=fakeTeamToken -F notes='fake notes'"
	./testflight_post -d -u "fakeUploadToken" -t "fakeTeamToken" test/fake.ipa "fake notes" > ./results.txt
	firstline=`head -1 ./results.txt`
	assertEquals "${EXPECTED}" "${firstline}"
}

testScriptShouldSetFileCorrectly()
{
	DATA_PATH="test/fake.ipa"
	EXPECTED="file=@$DATA_PATH"
	./testflight_post -d -u "fakeUploadToken" -t "fakeTeamToken" "$DATA_PATH" "fake notes" | grep -q "${EXPECTED}"
	assertTrue "expecting correct file path" "$?"
}

testScriptShouldSetUploadTokenCorrectly()
{
	TOKEN="fakeUploadToken"
	EXPECTED="api_token=$TOKEN"
	./testflight_post -d -u "$TOKEN" -t "fakeTeamToken" test/fake.ipa "fake notes" | grep -q "${EXPECTED}"
	assertTrue "expecting correct file path" "$?"
}

testScriptShouldSetTeamTokenCorrectly()
{
	TOKEN="fakeTeamToken"
	EXPECTED="team_token=$TOKEN"
	./testflight_post -d -u "$TOKEN" -t "fakeTeamToken" test/fake.ipa "fake notes" | grep -q "${EXPECTED}"
	assertTrue "expecting correct file path" "$?"
}

testScriptShouldSetNotesCorrectly()
{
	NOTES="expected notes"
	EXPECTED="notes='${NOTES}'"
	./testflight_post -d -u "fakeUploadToken" -t "fakeTeamToken" test/fake.ipa "${NOTES}" | grep -q "${EXPECTED}"
	assertTrue "expecting correct file path" "$?"
}

testScriptShouldUseDefaultTestFlightUrl()
{
	EXPECTED="http://testflightapp.com/api/builds.json"
	./testflight_post -d -u "fakeUploadToken" -t "fakeTeamToken" test/fake.ipa "fake notes" | grep -q "curl "${EXPECTED}""
	assertTrue "expecting correct url" "$?"
}

testZFlagShouldAddDsym()
{
	EXPECTED="curl http://testflightapp.com/api/builds.json -F file=@test/fake.ipa -F dsym=@test/fake.dSYM -F api_token=fakeUploadToken -F team_token=fakeTeamToken -F notes='fake notes'"
	./testflight_post -d -u "fakeUploadToken" -t "fakeTeamToken" -z test/fake.dSYM test/fake.ipa "fake notes" > ./results.txt
	firstline=`head -1 ./results.txt`
	assertEquals "${EXPECTED}" "${firstline}"
}

testScriptShouldSetDsymCorrectly()
{
	DSYM_PATH="test/fake.dSYM"
	EXPECTED="dsym=@$DSYM_PATH"
	./testflight_post -d -n -u "fakeUploadToken" -t "fakeTeamToken" -z "$DSYM_PATH" test/fake.ipa "fake notes" | grep -q "${EXPECTED}"
	assertTrue "expecting correct dSYM url" "$?"
}

testNFlagShouldSetNotifyCorrecty()
{
	EXPECTED="notify=True"
	./testflight_post -d -n -u "fakeUploadToken" -t "fakeTeamToken" -z test/fake.dSYM test/fake.ipa "fake notes" | grep -q "${EXPECTED}"
	assertTrue "expecting correct file path" "$?"
}

testHFlagShouldOutputHelp()
{	
	EXPECTED='Expected output differs.'
	./testflight_post -h > ./results.txt
	diff ./test/expected_help.txt ./results.txt
	assertTrue "${EXPECTED}" $?
}

# run shunit2
SHUNIT_PARENT=$0 . $SHUNIT2