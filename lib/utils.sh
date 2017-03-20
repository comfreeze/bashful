#!/usr/bin/env bash

#
# Generic command builder
#
assemble_command () {
  command="$1";     shift;
  [[ "${_FAKE}" = true ]] && command="echo ${command}"
  for _OPT_ in "$*"; do
    verbose 3 "Adding option ${_OPT_}"
    command+=" ${_OPT_}"
  done
  printf '%s' "${command}"
}
export -f assemble_command
#
# Append options to a variable value
#
apply_option () {
  local name;
  name=$1; shift
  eval "export ${name}=\"$* ${!name}\"";
  return 0;
}
export -f apply_option
#
# Append options to a collection of variable values
#
apply_options () {
  local CMDS; local OPTS;
  eval "CMDS=( \"\${${1}[@]}\" )"; shift
  for CMD in "${CMDS[@]}"; do
    eval "export ${CMD}=\"${!CMD} $*\"";
    dump "${CMD}"
  done
  return 0;
}
export -f apply_options