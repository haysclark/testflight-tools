#!/usr/bin/env bats

setup() {
	EXPECTED_USAGE="Usage: ./testflight_post [-h] [-v] [-d] [-a] [-n] [-c custCurl] [-w custUrl] [-u uploadToken] [-t teamToken] [-z dSYMfile] [datafile] [notes]"
}

@test "Check that the testflight_post client is available" {
    command -v testflight_post
}

@test "Script Should Output Expected Requirements" {
	run testflight_post

	[ "$status" -eq 1 ]
	[ "${lines[0]}" = "file path is required and must be supplied or set in the script" ]
	#[ "${lines[1]}" = "${EXPECTED_USAGE}" ]
}

@test "Script Should Warn If Release Notes Are Missing" {
	run testflight_post test/fake.ipa
	
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = "release notes are required and must be supplied or set in the script" ]
	#[ "${lines[1]}" = "${EXPECTED_USAGE}" ]
}

@test "Script Should Warn If Api Token Is Missing" {
	run testflight_post test/fake.ipa "fake notes"
	
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = "api_token is not supplied and is file path is required" ]
	#[ "${lines[1]}" = "${EXPECTED_USAGE}" ]
}

@test "Script Should Warn If Team Token Is Missings" {
	run testflight_post -u "fakeUploadToken" test/fake.ipa "fake notes"
	
	[ "$status" -eq 1 ]
	[ "${lines[0]}" = "team_token is not supplied and is file path is required" ]
	#[ "${lines[1]}" = "${EXPECTED_USAGE}" ]
}

@test "Script Should Attempt Upload If All Needed Argument Are Used" {
	run testflight_post -u "fakeUploadToken" -t "fakeTeamToken" test/fake.ipa "fake notes"
	
	[ "$status" -eq 0 ]
}

@test "Script Should Default To Curl" {
	run testflight_post -d -u "fakeUploadToken" -t "fakeTeamToken" test/fake.ipa "fake notes"

	[[ ${lines[0]} =~ "curl" ]]
 }

@test "C Flag Should Set Curl Alternative Command" {
	EXPECTED="furl"
	run testflight_post -d -c "${EXPECTED}" -u "fakeUploadToken" -t "fakeTeamToken" test/fake.ipa "fake notes"

	[[ ${lines[0]} =~ "${EXPECTED}" ]]
}

@test "W Flag Should Set Url" {
	EXPECTED="http::/foo/"
 	run testflight_post -d -w "${EXPECTED}" -u "fakeUploadToken" -t "fakeTeamToken" test/fake.ipa "fake notes"

	[[ ${lines[0]} =~ "${EXPECTED}" ]]
}

@test "Script Should Output Expected Version" {
	run testflight_post -v

	[ "$status" -eq 1 ]
	[[ ${lines[0]} =~ "testflight_post version " ]]
	[[ ${lines[0]} =~ "1.1" ]]
}

@test "D Flag Should Perform Dry Run" {
	run testflight_post -d -u "fakeUploadToken" -t "fakeTeamToken" test/fake.ipa "fake notes"

	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "curl http://testflightapp.com/api/builds.json -F file=@test/fake.ipa -F api_token=fakeUploadToken -F team_token=fakeTeamToken -F notes='fake notes'" ]
}

@test "Script Should Set File Correctly" {
	DATA_PATH="test/fake.ipa"
	run testflight_post -d -u "fakeUploadToken" -t "fakeTeamToken" "$DATA_PATH" "fake notes"

	[[ ${lines[0]} =~ "file=@$DATA_PATH" ]]
}

@test "Script Should Set Upload Token Correctly" {
	TOKEN="fakeUploadToken"
	run testflight_post -d -u "$TOKEN" -t "fakeTeamToken" test/fake.ipa "fake notes"
	
	[[ ${lines[0]} =~ "api_token=$TOKEN" ]]
}

@test "Script Should Set Team Token Correctly" {
	TOKEN="fakeTeamToken"
	run testflight_post -d -u "$TOKEN" -t "fakeTeamToken" test/fake.ipa "fake notes" 

	[[ ${lines[0]} =~ "team_token=$TOKEN" ]]
}

@test "Script Should Set Notes Correctly" {
	NOTES="expected notes"
	run testflight_post -d -u "fakeUploadToken" -t "fakeTeamToken" test/fake.ipa "${NOTES}"

	[[ ${lines[0]} =~ "notes='${NOTES}'" ]]
}

@test "Script Should Use Default TestFlight Url" {
	run testflight_post -d -u "fakeUploadToken" -t "fakeTeamToken" test/fake.ipa "fake notes"

	[[ ${lines[0]} =~ "http://testflightapp.com/api/builds.json" ]]
}

@test "Z Flag Should Add Dsym" {
	run testflight_post -d -u "fakeUploadToken" -t "fakeTeamToken" -z test/fake.dSYM test/fake.ipa "fake notes"

	[[ ${lines[0]} =~ "dsym=@test/fake.dSYM" ]]
}

@test "Script Should Set Dsym Correctly" {
	DSYM_PATH="test/fake.dSYM"
	run testflight_post -d -n -u "fakeUploadToken" -t "fakeTeamToken" -z "$DSYM_PATH" test/fake.ipa "fake notes"

	[[ ${lines[0]} =~ "dsym=@$DSYM_PATH" ]]
}

@test "N Flag Should Set Notify Correcty" {
	run testflight_post -d -n -u "fakeUploadToken" -t "fakeTeamToken" -z test/fake.dSYM test/fake.ipa "fake notes"

	[[ ${lines[0]} =~ "notify=True" ]]
}

@test "H Flag Should Output Help" {	
	run testflight_post -h

	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "Usage: testflight_post [-h] [-v] [-d] [-a] [-n] [-c custCurl] [-w custUrl] [-u uploadToken] [-t teamToken] [-z dSYMfile] [datafile] [notes]" ]
	[ "${lines[1]}" = "Options" ]
	[ "${lines[2]}" = " -v            	   show version" ]
	[ "${lines[3]}" = " -d            	   dry run, only show curl command" ]
	[ "${lines[4]}" = " -a            	   auto-open TestFlight" ]
	[ "${lines[5]}" = " -n            	   enable notify" ]
	[ "${lines[6]}" = " -c            	   override curl command" ]
	[ "${lines[7]}" = " -w            	   override TestFlight www url" ]
	[ "${lines[8]}" = " -u            	   set upload API token" ]
	[ "${lines[9]}" = " -t            	   set team API token" ]
	[ "${lines[10]}" = " -z            	   set path of dSYM zip file" ]
	[ "${lines[11]}" = "(-h)           	   show this help" ]
}
