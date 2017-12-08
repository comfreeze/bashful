#!/usr/bin/env bash

#
# CONFIG
###################
_DATE=`which date`
_UTC=true

#
# LIBRARIES
###################
require output
require colors

#
# MODULE LOGIC
###################
# Current date helper
function current_date ()
{
  dump_method $*
  ${_DATE} +%F
}
export -f current_date
# Current time helper
function current_time ()
{
  dump_method $*
  ${_DATE} +%T
}
export -f current_time
# Current timestamp
function current_timestamp ()
{
  dump_method $*
  ${_DATE} +%s
}
export -f current_timestamp
# UTC setting read helper
function set_utc ()
{
  dump_method $*
  local value;  value=${1-"true"};  shift
  _UTC="${value}"
}
# UTC setting read helper
function is_utc ()
{
  dump_method $*
  [[ "${_UTC}" == "true" ]] && return 1
  return 0
}

#
# EXPOSED ACTIONS
###################
param_utc ()        { _UTC=true }

#
# INITIALIZATION
###################
[[ is_fake ]] && _DATE="echo ${_DATE}"
[[ is_utc  ]] && _DATE="${_DATE} --utc"