#!/usr/bin/env bash

#
# CONFIG
###################
__CURL_PARAMS=${CURL_PARAMS-"-L -o"}
__WGET_PARAMS=${WGET_PARAMS-"-O"}
DOWNLOADER=

#
# CUSTOM LIBRARIES
###################

#
# MODULE LOGIC
###################
#
# Custom parameter options
#

#
# Download app locator
#
function downloader ()
{
    dump_method "$@"
    CMD=`which curl`
    if [[ ! ${CMD} = "" ]]; then
        echo "${CMD} ${__CURL_PARAMS} "
    fi
    CMD=`which wget`
    if [[ ! ${CMD} = "" ]]; then
        echo "${CMD} ${__WGET_PARAMS} "
    fi
}
export -f downloader

#
# MODULE INITIALIZATION
###################
DOWNLOADER=$( downloader )
