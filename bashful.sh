#!/usr/bin/env bash

#
# GENERAL CONFIG
###################
set +a
shopt -s extglob
special=$( echo @|tr @ '\034' );
## Local Overrides Filename
_ENVFILE="local.env"
## Bash Version
_BV=$( echo ${BASH_VERSION} | cut -d"." -f1 )

#
# DEBUG CONFIG
###################
## Verbosity Level
_V=0
__TRACE=4
__DEBUG=3
__INFO=2
__WARN=1
__ERROR=0
__SILENT=999
## Fake Commands
_FAKE=false
## Interactivity Toggle
_INTERACTIVE=false

#
# DEPENDENCY CONFIG
###################
## Default Dependency Extension
_EXTENSION=".sh"
## Library Root Directory
_LIB_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
## Runtime Dependency Directory
_SCRIPT_PATH=$( dirname -- "$0" )
## Dependency Path Index
_PATHS=()
_PATHS+=( "${_LIB_DIR}" )
_PATHS+=( "${_SCRIPT_PATH}" )
## Active Command Index
_COMMANDS=()
## Processing Command Collections
__WORKING_COMMAND=""
declare -a __WORKING_ARRAY

#
# DEPENDENCY LOGIC
###################
## Quick Verbosity Logger
function verbose ()
{
  local level;  level="$1";           shift
  local c;      c=( $( caller 0 ) );
  (( "${_V}" >= "${level}" )) && >&2 printf '%b\n' "$( printf '%-20s' "$( basename ${c[2]} ):${c[0]}" ) ${FUNCNAME[1]} $*"
}
## Require helper - locates and loads external scripts
function require ()
{
  local c; c=( $( caller 0 ) );
  verbose ${__INFO} "${RESET}${!_FG_LABEL}$( printf '%-20s' "$( basename ${c[2]} ):${c[0]}" )${RESET}${!_FG_VALUE} <-- $*"
  local target; target="$1";  shift
  local file;   file="${target}${_EXTENSION}";
  ## Loop specified dependency paths
  for path in "${_PATHS[@]}"; do
    ## Display current target
    verbose ${__TRACE} "Dependency Directory Search: ${path}"
    ## Check if directory exists
    [[ ! -d "${path}" ]] && verbose ${__TRACE} "Dependency Directory Not Found: ${path}" || \
    ## Check if module exists
    [[ ! -f "${path}/${file}" ]] && verbose ${__TRACE} "Dependency Module Not Found In Path: ${path}/${file}" || \
    ## Load the module - return on first match
    source "${path}/${file}" $@ && verbose ${__TRACE} "Dependency Module Loaded From Path: ${path}/${file}" && return
  done
  verbose ${__INFO} "${RESET}"
}
export -f require

#
# OVERRIDE LOGIC
###################
## Initialize Override Configurations
require verbosity $*
require config
## Initialize Local Configuration
load_config file "${_SCRIPT_PATH}/${_ENVFILE}"

#
# LOAD LIBRARIES
###################
require router

#
# ROUTING
###################
## Define Module Routes
route_load "$(cat <<ROUTE
[
	{
	  "namespace": "bashful",
	  "pattern": "-v*",
		"use": "-v|-vv|-vvv|-vvvv",
		"description": "Support various verbosity level specification.",
		"callback": "",
		"priority": "999"
	},
	{
	  "namespace": "bashful",
		"use": "-f|--fake",
		"description": "Replace commands with echo equivalents to output what would be run."
		"callback": "",
		"priority": "1"
	}
]
ROUTE
)"

#
# MODULE LOGIC
###################
## Primary execution point
function run ()
{
  dump_method "$@"
  require help $*
  route $*
}
export -f run