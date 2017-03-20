#!/usr/bin/env bash

shopt -s extglob
#
# Variables/Options
#
_ENVFILE="local.env"
_V=0
_FAKE=false
_BV=$( echo ${BASH_VERSION} | cut -d"." -f1 )
_INTERACTIVE=false
_LIB_DIR="lib"
_EXTENSION=".sh"
_SCRIPT_PATH=$( dirname -- "$0" )
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
require verbosity
require output
require utils
require filesystem
load_config "${_SCRIPT_PATH}/${_ENVFILE}"
