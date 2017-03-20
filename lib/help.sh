#!/usr/bin/env bash

#
# Libraries
#
require params
config_params PARAMS
require actions
config_actions ACTIONS

#
# Custom Methods
#
usage_command() {
  cat << EOF
${USAGE_TITLE}
 $0 (options) [actions] (parameters)
EOF
}
export -f usage_command

usage_options() {
  local i; i=0;
  echo " FLAGS:"
  for pi in $( param_count ); do
    printf '  %-30s - %s' "${_PP[${pi}]}" "${_PD[${pi}]}"
    echo
  done
}
export -f usage_options

usage_actions() {
  local i; i=0;
  echo " ACTIONS:"
  for ai in $( action_count ); do
    printf '  %-30s - %s' "${_AP[${ai}]}" "${_AD[${ai}]}"
    echo
  done
}
export -f usage_actions

usage_details() {
  cat << EOF
EOF
}

usage_advanced() {
  cat << EOF
EOF
}
_load_usage () {
  level=$1; shift
  usage=$1; shift
  eval "verb ${level} usage_${usage} $*"
}
#
# Capture defined usage functions
#
_USAGE_FUNCS=( $( columns $( declare -F | cut -d" " -f3 | grep -e "usage_" ) ) )
_USAGE_FUNCS=( "${_USAGE_FUNCS[@]#usage_}" )
#
# Usage information
#
usage () {
  for FUNC in "${_USAGE_FUNCS[@]}"; do
    if [[ "${FUNC}" = "$2" ]]; then
      local name; name=$2; shift
      _load_usage 0 $name $*
      exit 0
    fi
  done
  case "$2" in
    list)
      dump_array_pretty _USAGE_FUNCS
    ;;
    *)
      _load_usage 0 command
      _load_usage 0 options
      _load_usage 0 actions
      _load_usage 1 details
      _load_usage 2 advanced
      ;;
  esac
}
export -f usage
#
# Verbosity parameter parsing and to-level config
# setters as well as access to help immediately so
# script will exit quickly.
#
while test $# -gt 0; do
  case "$1" in
    help)
      shift
      usage $0 $*
      exit 1
    ;;
    *)
      OPTS=( "${OPTS[@]}" $1 )
      shift
    ;;
  esac
done
set -- ${OPTS[@]}