#!/usr/bin/env bash

#
# CONFIG
###################
_FAKE=false
_V_DUMP=1
_V_DUMP_PRETTY=2
_V_DUMP_METHOD=4
_FG_LABEL="FG_CYN"
_FG_VALUE="FG_YLW"

#
# LIBRARIES
###################
require output
require colors

#
# MODULE LOGIC
###################
#
# Verbosity helpers
#
verbose()
{
  if (( "${_V}" >= "$1" )); then
    shift; stderr $*
  fi
}
export -f verbose
#
# Verbosity helpers
#
verbosee()
{
  local level=$1;   shift;
  if (( "${_V}" >= "${level}" )); then
    $( _="$*" dump _ )
  fi
  eval "$*"
}
export -f verbosee
verbosef()
{
  if (( "${_V}" >= "$1" )); then
    shift; stderrf $*
  fi
}
export -f verbosef
verboses()
{
  local level; level="%${_V}s"
  (( "${_V}" >= "1" )) && echo -n "-$( printf ${level} | tr " " "v" )"
}
export -f verboses
verb()
{
  if (( "${_V}" >= "$1" )); then
    shift; $*
  fi
}
export -f verb
#
# Debugging helpers
#
dump ()
{
  if (( "${_V}" >= "${_V_DUMP}" )); then
    stderr "${RESET}${!_FG_LABEL}$1=${RESET}${!_FG_VALUE}\"${!1}\"${RESET}"
  fi
}
export -f dump
dump_raw ()
{
  if (( "${_V}" >= "${_V_DUMP}" )); then
    stderr "${RESET}${!_FG_VALUE}${!1}${RESET}"
  fi
}
export -f dump_raw
dump_method ()
{
  local c; c=( $( caller 0 ) );
  verbose ${_V_DUMP_METHOD} "${RESET}${!_FG_LABEL}$( basename ${c[2]} ) [${c[0]}]:${RESET}${!_FG_VALUE} ${FUNCNAME[1]} $*${RESET}"
}
export -f dump_method
dump_array ()
{
  eval "verbose 2 \"${RESET}${!_FG_LABEL}$1=${RESET}${!_FG_VALUE}\"\${${1}[@]}\"\"${RESET}"
}
export -f dump_array
dump_array_pretty ()
{
  eval "target=( \"\${${1}[@]}\" )"
  local l; l=${2-"${1}"}
  verbose ${_V_DUMP_PRETTY} "${RESET}${!_FG_LABEL}${l}=${RESET}${!_FG_VALUE}("
  for ITEM in "${target[@]}"; do
    verbosef ${_V_DUMP_PRETTY} "\\t%s\\n" "${ITEM}"
  done
  verbose ${_V_DUMP_PRETTY} ")${RESET}"
}
export -f dump_array_pretty
dump_assoc_array ()
{
  eval "target=( \"\${${1}[@]}\" )"
  verbose ${_V_DUMP_PRETTY} "${RESET}${!_FG_LABEL}$1=${RESET}${!_FG_VALUE}("
  for ITEM in "${target[@]}"; do
    KEY="${ITEM%%=*}"; VALUE="${ITEM##*=}";
    verbose ${_V_DUMP_PRETTY} "${KEY}"
  done
  verbose ${_V_DUMP_PRETTY} ")${RESET}"
}
export -f dump_assoc_array
is_fake ()
{
  [[ "${_FAKE}" == true ]] && return 0;
  return 1
}
export -f is_fake
#
# PARAMETERS
###################
param_verbosity ()      { _V="$( grep -o "v" <<< "$1" | wc -l )"; } #echo "Verbosity: ${_V}"; }
usage_verbosity ()      { echo "-v|-vv|-vvv|-vvvv|-vvvvv|-vvvvvv"; }
describe_verbosity ()   { echo "Support various verbosity level specification."; }
help_verbosity ()       { cat << EOF

Description:
  $( describe_verbosity )  Manages the level of debugging output provided, higher values provide a lot of output.
EOF
}

is_fake ()              { [[ ${_FAKE} == true ]] && return 1 || return 0; }
param_fake ()           { _FAKE=true; }
usage_fake ()           { echo "-f|--fake"; }
describe_fake ()        { echo "Replace commands with echo equivalents to output what would be run."; }
help_fake ()            { cat << EOF

Description:
  $( describe_fake )  Signals to the system that instead of executing calls, each call should be printed instead.
EOF
}

#
# Verbosity parameter parsing and to-level config
# setters as well as access to help immediately so
# script will exit quickly.
#
while test $# -gt 0; do
  case "$1" in
    -v*)
      param_verbosity "$1"
#      echo "Verbosity: ${_V}"
      shift
    ;;
#    -f|--fake)
#      shift
#      echo "Faking commands"
#      _FAKE=true
#    ;;
#    -e|--env)
#      shift
#      _ENVFILE="$1"
#      dump 1 _ENVFILE
#      shift
#    ;;
    *)
      OPTS+=( $1 )
      shift
    ;;
  esac
done
set -- ${OPTS[@]}
(( "${_V}" >= "1" )) && set +ex
(( "${_V}" >= "3" )) && set +e
(( "${_V}" >= "5" )) && set -ex

case "$-" in
    *i*)    _INTERACTIVE=true ;;
esac