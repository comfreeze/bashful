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
prepend_option () {
  dump_method $*
  insert_option 0 $*
}
export -f prepend_option
#
# Append options to a variable value
#
apply_option () {
  dump_method $*
  insert_option 1 $*
}
export -f apply_option
#
# Insert options to a variable value
#
insert_option () {
  dump_method $*
  local POS;  POS=$1; shift
  local name; name=$1; shift
  if [[ "${POS}" = "0" ]]; then
    eval "export ${name}=\"$* ${!name}\"";
  else
    eval "export ${name}=\"${!name} $*\"";
  fi
  return 0;
}
export -f insert_option
#
# Append options to a collection of variable values
#
prepend_options () {
  dump_method $*
  insert_options 0 $*
}
export -f prepend_options
#
# Append options to a collection of variable values
#
apply_options () {
  dump_method $*
  insert_options 1 $*
}
export -f apply_options
#
# Append options to a collection of variable values
#
insert_options () {
  dump_method $*
  local POS;  POS=$1; shift
  local CMDS; eval "CMDS=( \"\${${1}[@]}\" )"; shift
  for CMD in "${CMDS[@]}"; do
    if [[ "${POS}" = "0" ]]; then
      eval "export ${CMD}=\"$* ${!CMD}\"";
    else
      eval "export ${CMD}=\"${!CMD} $*\"";
    fi
    dump "${CMD}"
  done
  return 0;
}
export -f insert_options