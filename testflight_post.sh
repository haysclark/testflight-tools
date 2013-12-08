#!/bin/bash
#
# Post to TestFlight 1.0, 2013
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of 
# this software and associated documentation files (the "Software"), to deal in 
# the Software without restriction, including without limitation the rights to 
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
# of the Software, and to permit persons to whom the Software is furnished to do 
# so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
# SOFTWARE.
# 
# Written by Hays Clark <hays@infinitedescent.com>
# 
# Latest version can be found at https://gist.github.com/haysclark/
# Tested on OSX (10.9)
# 
# Copyright (c) 2013 Hays Clark
#

#
# Test FLight API Docs - https://testflightapp.com/api/doc/#
#
# api_token - Required (Get your *Upload API token)
# --> https://testflightapp.com/account/#api
# team_token - Required, token for the team being uploaded to. (Get your team token)
# file - Required, file data for the build
# notes - Required, release notes for the build
# dsym - iOS ONLY - Optional, the zipped .dSYM corresponding to the build
# distribution_lists - Optional, comma separated distribution list names which will receive access to the build
# notify - Optional, notify permitted teammates to install the build (defaults to False)
# replace - Optional, replace binary for an existing build if one is found with the same name/bundle version (defaults to False)
#

# REQUIRED, hardcode or use flags to set
UPLOAD_TOKEN=""
TEAM_TOKEN=""
FILE="" 
NOTES="" 

# Optional
DSYM_PATH=""
DIST_LISTS=""
NOTIFY=0
REPLACE=0

# Script Options
CMD_PATH="curl"
TESTFLIGHT_URL="http://testflightapp.com/api/builds.json"

# Internal
NAME=`basename "$0"`
VERSION=1.0
DRY_RUN=0
AUTO_OPEN=0
MSG=""
EXPECTED_FLAGS="[-v] [-h] [-d] [-a] [-n] [-c curlfile] [-w testflighturl] [-z dSYMfile]  [datafile] [notes]"

while getopts "vhdanc:w:u:t:z:" VALUE "$@" ; do
	if [ "$VALUE" = "h" ] ; then
		echo usage: $NAME $EXPECTED_FLAGS
		echo
		echo "Options"
		echo " -v            	   show version"
		echo " -d            	   dry run, only show curl command"
		echo " -n            	   enable notify"
		echo " -c            	   override curl command"
		echo " -w            	   override TestFlight www url"
		echo " -u            	   set upload API token"
		echo " -t            	   set team API token"
		echo " -z            	   set path of dSYM zip file"
		echo "(-h)           	   show this help"
		exit 0
	fi
	if [ "$VALUE" = "v" ] ; then
		echo $NAME version $VERSION
	fi
	if [ "$VALUE" = "d" ] ; then
		DRY_RUN=1
	fi
	if [ "$VALUE" = "a" ] ; then
		AUTO_OPEN=1
	fi
	if [ "$VALUE" = "n" ] ; then
		NOTIFY=1
	fi
	if [ "$VALUE" = "c" ] ; then
		CMD_PATH="$OPTARG"
	fi
	if [ "$VALUE" = "w" ] ; then
		TESTFLIGHT_URL="$OPTARG"
	fi
	if [ "$VALUE" = "u" ] ; then
		UPLOAD_TOKEN="$OPTARG"
	fi
	if [ "$VALUE" = "t" ] ; then
		TEAM_TOKEN="$OPTARG"
	fi
	if [ "$VALUE" = "z" ] ; then
		DSYM_PATH="$OPTARG"
	fi
	if [ "$VALUE" = ":" ] ; then
        echo "Flag -$OPTARG requires an argument."
        echo "Usage: $0 $EXPECTED_FLAGS"
        exit 1
    fi
	if [ "$VALUE" = "?" ] ; then
		echo "Unknown flag -$OPTARG detected."
		echo "Usage: $0 $EXPECTED_FLAGS"
		exit 1
	fi
done

shift `expr $OPTIND - 1`

if [ "$#" -gt 2 ]; then
  echo "Too many arguments."
  echo "Usage: $0 $EXPECTED_FLAGS"
  exit 1
fi

if [ "$#" -eq 2 ]; then
	if ! [ -f "$1" ]; then
		echo "$1 is not a path to the IPA"
		echo "Usage: $0 $EXPECTED_FLAGS"
		exit 1
	fi
	FILE="$1"
	NOTES="$2"
fi

if [ "$#" -eq 1 ]; then
	if [ -f "$1" ]; then
		FILE="$1"
	else
		NOTES="$1"		
	fi
fi

if [ "$FILE" = "" ]; then
	echo "file path is required and must be supplied or set in the script"
	echo "Usage: $0 $EXPECTED_FLAGS"
	exit 1
fi

if ! [ -f "$FILE" ]; then
	echo $FILE" is not a valid filepath."
	echo "Usage: $0 $EXPECTED_FLAGS"
	exit 1
fi

if [ "$NOTES" = "" ]; then
	echo "release notes are required and must be supplied or set in the script"
	echo "Usage: $0 $EXPECTED_FLAGS"
	exit 1
fi

if [ "$UPLOAD_TOKEN" = "" ]; then
	echo "api_token is not supplied and is file path is required"
	echo "Usage: $0 $EXPECTED_FLAGS"
	exit 1
fi

if [ "$TEAM_TOKEN" = "" ]; then
echo "team_token is not supplied and is file path is required"
	echo "Usage: $0 $EXPECTED_FLAGS"
	exit 1
fi

#
#curl http://testflightapp.com/api/builds.json 
#   -F file=@testflightapp.ipa
#   -F dsym=@testflightapp.app.dSYM.zip
#   -F api_token='your_api_token' 
#   -F team_token='your_team_token' 
#   -F notes='This build was uploaded via the upload API' 
#   -F notify=True 
#   -F distribution_lists='Internal, QA'
#

MSG="$CMD_PATH"
MSG+=" $TESTFLIGHT_URL"
MSG+=" -F file=@$FILE"

if ! [ "$DSYM_PATH" = "" ]; then
	if ! [ -f "$DSYM_PATH" ]; then
		echo $DSYM_PATH" is not a valid filepath."
		echo "Usage: $0 $EXPECTED_FLAGS"
		exit 1
	fi
	MSG+=" -F dsym=@$DSYM_PATH"
fi

MSG+=" -F api_token=$UPLOAD_TOKEN"
MSG+=" -F team_token=$TEAM_TOKEN"
MSG+=" -F notes='$NOTES'"

if [ $NOTIFY = 1 ]; then
	MSG+=" -F notify=True"
fi

if ! [ "$DIST_LISTS" = "" ]; then
	MSG+=" -F distribution_lists=$DIST_LISTS"
fi

if [ "$DRY_RUN" = 1 ] ; then
	echo "$MSG"
	exit 0
fi

eval "$MSG"
echo
echo "Uploaded to TestFlight"

if [ $AUTO_OPEN = 1 ]; then
	open "https://testflightapp.com/dashboard/builds/"
fi
