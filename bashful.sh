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
  (( "${_V}" >= "${level}" )) && >&2 printf '%b\n' "$*"
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
#  verbose ${__INFO} "${RESET}"
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
# MODULE LOGIC
###################
## Verbosity controller
function set__vlevel ()
{
  export _V="$1";
}
export -f set__vlevel
## Verbosity controller - Count the V's
function set__vlevel_vs ()
{
  dump_method "$@"
  local level="$( grep -o "v" <<< "$1" | wc -l )";
  set__vlevel ${level}
  return 1
}
export -f set__vlevel_vs
## Verbosity controller - Direct string
function set__vlevel_string ()
{
  dump_method "$@"
  local level="__$( echo "$1" | tr '[:lower:]' '[:upper:]' )"
  set__vlevel "${!level}"
}
export -f set__vlevel_string
function get__vlevel ()
{
  echo "${_V}";
}
export -f get__vlevel
## Call Faking - Enabler
function set__vfake ()
{
  dump_method "$@"
  _FAKE=0;
}
export -f set__vfake
function get__vfake ()
{
  return ${_FAKE};
}
export -f get__vfake
function is_fake ()
{
  get__vfake && return 0 || return 1
}
export -f is_fake
## Call Faking - Echo Wrapper
#function fakeable ()
#{
#
#}
## Primary execution point
function run ()
{
  dump_method "$@"
  require help $*
  route $*
}
export -f run

#
# ROUTING
###################
## Define Module Routes
route_load "$(cat <<ROUTE
[
	{
	  "namespace": "verbosity",
	  "pattern": "-[v+]",
		"use": "-v|-vv|-vvv|-vvvv",
		"description": "Support various verbosity level specification.",
		"callback": "set__vlevel_vs",
		"priority": 999
	},
	{
	  "namespace": "verbosity",
		"use": "--error",
		"description": "Set verbosity to error explicitly.",
		"callback": "set__vlevel_string error",
		"priority": 999
	},
	{
	  "namespace": "verbosity",
		"use": "--warn",
		"description": "Set verbosity to warn explicitly.",
		"callback": "set__vlevel_string warn",
		"priority": 999
	},
	{
	  "namespace": "verbosity",
		"use": "--info",
		"description": "Set verbosity to info explicitly.",
		"callback": "set__vlevel_string info",
		"priority": 999
	},
	{
	  "namespace": "verbosity",
		"use": "--debug",
		"description": "Set verbosity to debug explicitly.",
		"callback": "set__vlevel_string debug",
		"priority": 999
	},
	{
	  "namespace": "verbosity",
		"use": "--trace",
		"description": "Set verbosity to trace explicitly.",
		"callback": "set__vlevel_string trace",
		"priority": 999
	}
]
ROUTE
)"
## Command Faking
route_load "$(cat <<ROUTE
{
  "namespace": "bashful",
  "use": "-f|--fake",
  "description": "Replace commands with echo equivalents to output what would be run.",
  "callback": "set__vfake",
  "priority": 1
}
ROUTE
)"
## Route Testing
#route_list