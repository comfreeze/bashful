#!/usr/bin/env bash

#
# Variables/Options
#
declare -a _PP
declare -a _PV
declare -a _PT
declare -a _PD
#
# Require libraries
#
require array
#
# Clear parameters
#
clear_params () {
  dump_method $*
  unset _PP; unset _PV; unset _PT; unset _PD;
}
#
# Read defined parameters
#
config_params () {
  dump_method $*
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
export -f config_params
#
# Use defined parameters to set globals
#
eval_params () {
  dump_method $*
  local test; local var; local type; local pt;
  for up in $*; do
    for pi in $( param_count ); do
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
param_count () {
  dump_method $*
  local i; i=0
  while [ "$i" -lt "${#_PP[@]}" ]; do
    echo -n "${i} "; i=$[$i+1];
  done
}
export -f param_count
#
# Parameter parsing
#
#config_params PARAMS
