#!/usr/bin/env bash

#
# Variables/Options
#
declare -a _AP
declare -a _AT
declare -a _AM
declare -a _AD
#
# Require libraries
#
require array
#
# Clear parameters
#
clear_actions () {
  dump_method $*
  unset _AP; unset _AT; unset _AM; unset _AD;
}
#
# Read defined parameters
#
config_actions () {
  dump_method $*
  clear_actions
  eval "__A=( \"\${${1}[@]}\" )"; shift
#  dump_array __A
  local e;
  for ACTION in "${__A[@]}"; do
    e=( $( explode_array = "${ACTION// /_X-X_}" ) )
    _AP=( "${_AP[@]}" "${e[0]}" );
    _AT=( "${_AT[@]}" "${e[1]}" );
    _AM=( "${_AM[@]}" "${e[2]//_X-X_/ }" );
    _AD=( "${_AD[@]}" "${e[3]//_X-X_/ }" );
  done
}
export -f config_actions
#
# Use defined parameters to set globals
#
eval_actions () {
  dump_method $*
  local actions; local action; local method; local type;
  actions=$*;
  for ua in $*; do
    for ai in $( action_count ); do
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
action_count () {
  dump_method $*
  local i; i=0
  while [ "$i" -lt "${#_AP[@]}" ]; do
    echo -n "${i} "; i=$[$i+1];
  done
}
export -f action_count
#
# Parameter parsing
#
#config_actions ACTIONS
