testflight-tools [![Build Status](https://travis-ci.org/haysclark/testflight-tools.png)](https://travis-ci.org/haysclark/testflight-tools)
================

TestFlight-tools is an un-official command-line tool which is a convince wrapper for the Official TestFlight upload API.  The should script, 'testflight_post', makes it very easy to push iOS IPA's or Android APK's to TestFlight.  The intent of the script is to be integrated into Jenkins or other deployment environments or to simple run locally and be triggered via Terminal.

Enjoy!

* [TestFlight's official website](http://testflightapp.com/)

#### Features

* Dry Run, to see the curl command without actually executing it
* Auto-open TestFlight after upload
* Support for optional dSYM file
* Support of the 'notify' flag
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
