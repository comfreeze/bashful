#!/usr/bin/env bash

#
# CONFIG
###################
_BASE64_CMD=$( which base64 )

#
# LIBRARIES
###################

#
# CUSTOM LOGIC
###################
base64_decode () {
  dump_method $*
  echo "$*" | ${_BASE64_CMD} --decode
}
export -f base64_decode
base64_encode () {
  dump_method $*
  local data;   data="${!1}";
  echo "$( echo "${data}" | ${_BASE64_CMD} --wrap=0 )"
}
export -f base64_encode
