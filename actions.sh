#!/usr/bin/env bash

#
# Variables/Options
#
declare -a _AP
declare -a _AT
declare -a _AM
declare -a _AD
__ACTIONS_WORKING__=""
#
# Require libraries
#
require base64
require yaml
require array
#
# Clear parameters
#
clear_actions () {
  dump_method "$@"
  unset _AP; unset _AT; unset _AM; unset _AD;
}
#
# Read defined parameters
#
config_actions () {
  dump_method "$@"
  case $1 in
    yaml64) shift;  config_actions_yaml64 "$*"  ;;
    yaml)   shift;  config_actions_yaml "$*"    ;;
    bash)   shift;  config_actions_bash "$*"    ;;
    *)              config_actions_bash "$*"    ;;
  esac
}
export -f config_actions
#
# Read defined parameters
#
config_actions_bash () {
  dump_method "$@"
  local field=$( echo @|tr @ '\034' );
  clear_actions
  eval "__A=( \"\${${1}[@]}\" )"; shift
#  dump_array __A
  local e;
  for ACTION in "${__A[@]}"; do
    e=( $( explode_array = "${ACTION// /${field}}" ) )
    _AP=( "${_AP[@]}" "${e[0]}" );
    _AT=( "${_AT[@]}" "${e[1]}" );
    _AM=( "${_AM[@]}" "${e[2]//${field}/ }" );
    _AD=( "${_AD[@]}" "${e[3]//${field}/ }" );
  done
}
#
# Base64 decode input before processing
#
config_actions_yaml64 () {
  dump_method "$@"
  __ACTIONS_WORKING__="$( base64_decode ${!1} )";
  echo "$( config_actions_yaml __ACTIONS_WORKING__ )"
}
#
# Read a YAML string for actions
#
config_actions_yaml () {
  dump_method "$@"
  local data;       eval "data=\"\${${1}}\""
  local prefix;     prefix=${2-""}
  local separator;  separator=${3-"_"}
  local TEMP_FILE;  TEMP_FILE=$( working_file )
  echo "${data}" > "${TEMP_FILE}"
  __ACTIONS_WORKING__=( $( parse_yaml "${TEMP_FILE}" "${prefix}" "${separator}" ) )
  for ITEM in "${__ACTIONS_WORKING__[@]}"; do
    action=$( echo "${ITEM%_*}" );
    type=$( echo "${ITEM##*_}" | cut -d"=" -f1 );
    value="${ITEM##*=}";
    value="${value//%20/ }"
    case "${type}" in
      keywords)     _AP=( "${_AP[@]}" "${value}" )  ;;
      type)         _AT=( "${_AT[@]}" "${value}" )  ;;
      target)       _AM=( "${_AM[@]}" "${value}" )  ;;
      description)  _AD=( "${_AD[@]}" "${value}" )  ;;
    esac
  done
  rm -rf ${TEMP_FILE}
}
#
# Use defined parameters to set globals
#
eval_actions () {
  dump_method "$@"
  local actions; local action; local method; local type;
  actions=$*;
  for ua in $*; do
    for ai in $( bashful_actn_count ); do
      action="${_AP[${ai}]}"; method="${_AM[${ai}]}"; type="${_AT[${ai}]}";
      at=( $( explode_array "|" "${action}" ) )
      for a in "${at[@]}"; do
        if [[ "${ua}" = "${a}" ]]; then
          verbose 1 "Matched ${action}"
          case "${type}" in
            -*)
              shift
              # Ignore parameters
              ;;
            *|function|method)
              shift
              eval "${method} $*"
              exit $?
              ;;
          esac
        fi
      done
    done
  done
}
export -f eval_actions
