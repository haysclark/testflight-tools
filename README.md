testflight-tools
================

[![Build Status](https://travis-ci.org/haysclark/testflight-tools.sh.svg?branch=master)](https://travis-ci.org/haysclark/testflight-tools.sh)

TestFlight-tools is an un-official command-line tool set which wraps the Official TestFlight upload API.  Currently the soul script, 'testflight_post', makes it very easy to push iOS IPA's or Android APK's to TestFlight.  The script is intented to be integrated into Jenkins or other CI automation environments or to simple be run locally via Terminal.

Enjoy!

* [TestFlight's official website](http://testflightapp.com/)

#### Features

* Dry run, to see the curl command without actually executing it
* Auto-open TestFlight after upload
* Support optional TestFlight features like dSYM file and notify
* UnitTested via Travis-CI and shunit2 

Installation
------------

After cloning the repo, simply copy the `testflight_post` script out of the repo or setup a sym-link.

For "Help" run to following command:

```
./testflight_post -h
```

The simplest way to upload a IPA or APK with the tool is with the follwing command:

```
./testflight_post -u "yourUploadToken" -t "yourTeamToken" pathToYour.ipa "Your release notes"
```

Notes
------------

TestFlight requires the Upload Token and Team Token; however, in the script these optional flags as the script supports these values being hard-coded.  To hard code the values simply open the shell script and look for the first two variables.

```
UPLOAD_TOKEN=""
TEAM_TOKEN=""
```
