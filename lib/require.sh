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
_LIB_DIR="lib"
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
require () {
  (( "${_V}" >= "5" )) && echo "lib: ${1}"
  REQ="${_LIB_DIR}/${1}${_EXTENSION}"; shift
  if [[ -f "${_SCRIPT_PATH}/${REQ}" ]]; then
    source "${_SCRIPT_PATH}/${REQ}" $@
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
run () {
  dump_method $*
  require help $*
  eval_request $*
  local act;    act="$( get_action )"; shift
#  dump act
  ${act}
}