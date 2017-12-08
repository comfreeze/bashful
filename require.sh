#!/usr/bin/env bash

set +a
shopt -s extglob
special=$( echo @|tr @ '\034' );

#
# CONFIG
###################
_ENVFILE="local.env"
_V=0
_FAKE=false
_BV=$( echo ${BASH_VERSION} | cut -d"." -f1 )
_INTERACTIVE=false
_LIB_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_EXTENSION=".sh"
_SCRIPT_PATH=$( dirname -- "$0" )
_COMMANDS=()
_PREFIX_PARAM="param_"
_PREFIX_ACTION="action_"
_PREFIX_DESCRIPTION="describe_"

#
# MODULE LOGIC
###################
#
# Define our base require logic helper
#
function require ()
{
  (( "${_V}" >= "5" )) && echo "lib: ${1}"
  TARGET="${1}${_EXTENSION}"; shift
  REQ="${_LIB_DIR}/${TARGET}";
  if [[ -f "${REQ}" ]]; then
    source "${REQ}" $@
  fi
  REQ="${_SCRIPT_PATH}/${TARGET}"; shift
  if [[ -f "${REQ}" ]]; then
    source "${REQ}" $@
  fi
}
export -f require
#
# Load environment configuration
#
require verbosity $*
require output
require utils
require filesystem
require config

load_config file "${_SCRIPT_PATH}/${_ENVFILE}"
#
# Primary execution point
#
function run ()
{
  dump_method $*
  require help $*
  eval_request $*
  local act;    act="$( get_action )"; shift
#  dump act
  ${act}
  reset_colors
}
export -f run
#
# Support library locator
#
function bashful_root ()
{
  dump_method $*
  echo "${_LIB_DIR}"
}
#
# Script root locator
#
function script_root ()
{
  dump_method $*
  echo "${_SCRIPT_PATH}"
}