#!/usr/bin/env bash

#
# CONFIG
###################
declare -a _PP
declare -a _PV
declare -a _PT
declare -a _PD
__PARAMS_WORKING__=""
#
# LIBRARIES
###################
require array

#
# MODULE LOGIC
###################
#
# Clear parameters
#
clear_params () {
  dump_method "$@"
  unset _PP; unset _PV; unset _PT; unset _PD;
}
#
# Read defined parameters
#
config_params ()
{
  dump_method "$@"
  case $1 in
    yaml64) shift;  config_params_yaml64 "$*"   ;;
    yaml)   shift;  config_params_yaml "$*"     ;;
    *)              config_params_bash "$*"     ;;
  esac
}
export -f config_params

config_params_bash ()
{
  dump_method "$@"
  clear_params
  eval "__P=( \"\${${1}[@]}\" )"; shift
#  dump_array __P
  local e;
  for PARAM in "${__P[@]}"; do
    e=( $( explode_array = "${PARAM// /_X-X_}" ) )
    _PP=( "${_PP[@]}" "${e[0]}" );
    _PV=( "${_PV[@]}" "${e[1]}" );
    _PT=( "${_PT[@]}" "${e[2]//_X-X_/ }" );
    _PD=( "${_PD[@]}" "${e[3]//_X-X_/ }" );
  done
}
export -f config_params_bash
#
# Base64 decode input before processing
#
config_params_yaml64 ()
{
  dump_method "$@"
  __PARAMS_WORKING__="$( base64_decode ${!1} )";
  echo "$( config_params_yaml __PARAMS_WORKING__ )"
}
#
# Read a YAML string for params
#
config_params_yaml ()
{
  dump_method "$@"
  local data;       eval "data=\"\${${1}}\""
  local prefix;     prefix=${2-""}
  local separator;  separator=${3-"_"}
  local TEMP_FILE;  TEMP_FILE=$( working_file )
  echo "${data}" > "${TEMP_FILE}"
  __PARAMS_WORKING__=( $( parse_yaml "${TEMP_FILE}" "${prefix}" "${separator}" ) )
  for ITEM in "${__PARAMS_WORKING__[@]}"; do
    param=$( echo "${ITEM%_*}" );
    type=$( echo "${ITEM##*_}" | cut -d"=" -f1 );
    value="${ITEM##*=}";
    value="${value//%20/ }"
    case "${type}" in
      flags)        _PP=( "${_PP[@]}" "${value}" )  ;;
      type)         _PT=( "${_PT[@]}" "${value}" )  ;;
      target)       _PM=( "${_PM[@]}" "${value}" )  ;;
      description)  _PD=( "${_PD[@]}" "${value}" )  ;;
    esac
  done
  rm -rf ${TEMP_FILE}
}
#
# Use defined parameters to set globals
#
eval_params ()
{
  dump_method "$@"
  local test; local var; local type; local pt;
  for up in $*; do
    for pi in $( bashful_param_count ); do
      param="${_PP[${pi}]}"; var="${_PV[${pi}]}"; type="${_PT[${pi}]}";
      pt=( $( explode_array "|" "${param}" ) )
      for p in "${pt[@]}"; do
        if [[ "${up}" == "${p}" ]]; then
          verbose 1 "Matched ${param}"
          shift
          case "${type}" in
            boolean)
              eval "export ${var}=true"
              dump ${var}
              ;;
            *|string)
              eval "export ${var}=$1"
              dump ${var}
              shift
              ;;
            array)
              eval "export ${var}=( \"\${${var}[@]}\" \"$1\" )"
              dump ${var}
              shift
              ;;
          esac
        fi
      done
    done
  done
}
export -f eval_params
#
# Parameter parsing
#
#config_params PARAMS
