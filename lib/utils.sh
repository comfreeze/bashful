#!/usr/bin/env bash

#
# CONFIG
###################
__WORKING_COMMAND=""
declare -a __WORKING_ARRAY

#
# LIBRARIES
###################
require string

#
# MODULE LOGIC
###################
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
#    dump "${CMD}"
  done
  return 0;
}
export -f insert_options
#
# Find defined variables
#
get_functions () {
  local filter; filter="${1-""}";
  local remove; remove="${2-"true"}";
  local data;   data=( "$( declare -F | cut -d" " -f3 | grep -e "${filter}" )" )
  local out;    declare -a out;
  for d in "${data[@]}"; do
    [[ "${remove}" = "true" ]] && d=( "${d//${filter}/}" )
    out+=( "${d}" )
  done
  echo "${out[@]}"
}
export -f get_functions
#
# Provide if the first parameter is a defined function
# in the current shell scope.
#
is_function () {
  dump_method $*
  if [ -n "$(type -t $1)" ] && [ "$(type -t $1)" = function ]; then
    echo "true";
  else
    echo "false";
  fi
}
export -f is_function
#
# Get the output of a function as a string (or default output)
# or echo default (default: "")
#
get_function_output () {
  dump_method $*
  local f; f=${1-""};
  local d; d=${2-""};
  if [[ "$( is_function "${f}" )" = "true" ]]; then
    echo "$( ${f} )"
  else
    echo "${d}"
  fi
}
export -f get_function_output
#
# Generate filter string for usage group.
#
get_usage_group_filter () {
  dump_method $*
  local prefix; prefix=${1-""};     shift
  local remove; remove=${1-"true"}; shift
  local items;  items=( $( get_functions "${prefix}" "${remove}" ) )
  local out;    out="";
  for i in "${items[@]}"; do
    [[ "${#out}" > "0" ]] && out+="|"
    out+=$( get_usage_short "$i" );
  done
  echo "${out//\|\|/\|}"
}
export -f get_usage_group_filter
#
# Evaluate request
#
eval_request () {
  dump_method $*
  __WORKING_ARRAY=()
  local p; p="$( get_usage_group_filter param_ )"
  local a; a="$( get_usage_group_filter action_ )"
  while test $# -gt 0; do
    case "true" in
      $( in_string "|$1|" "|${p}|" ))
        set -- $( eval_param $* )
      ;;
      $( in_string "|$1|" "|${a}|" ))
        eval_action $*
        return
      ;;
      *)
        local t; t=$1; dump t
        __WORKING_ARRAY+=( $1 );
        dump_array_pretty __WORKING_ARRAY
        shift
      ;;
    esac
  done
  echo ${__WORKING_ARRAY[@]}
}
export -f eval_request
#
# Evaluate parameter
#
eval_param () {
  dump_method $*
  local cmd;    cmd="";
  local funcs;  funcs=( $( get_functions "${_PREFIX_PARAM}" ) )
  while test $# -gt 0; do
    local t;    t=$( find_target funcs "$1" );
    if [[ ! -z "${t}" ]]; then
      local u;  u=( $( get_usage "${t}" ) );
      local i;  i="${#u[@]}";
      cmd="${_PREFIX_PARAM}${t}"
      while test ${i} -gt 0; do
        cmd+=" $1"; shift;
        i=$((${i}-1));
      done
      eval "${cmd}";
    else
      break
    fi
  done
  echo $*
}
#
# Evaluate action
#
eval_action () {
  dump_method $*
  local cmd;    cmd="";
  local funcs;  funcs=( $( get_functions "${_PREFIX_ACTION}" ) )
  while test $# -gt 0; do
    local t;    t=$( find_target funcs "$1" );
    if [[ ! -z "${t}" ]]; then
      cmd="action_${t}"; shift;
      __WORKING_COMMAND="${cmd} $*";
      echo ""
      return 0
    fi
  done
  dump __WORKING_COMMAND
  echo $*
}
get_action () {
  dump_method $*
  echo "${__WORKING_COMMAND}"
}
#
# Identify target
#
find_target () {
  dump_method $*
  local s;      eval "s=( \"\${${1}[@]}\" )";   shift;
  local t;      t=$1;                           shift;
  for i in "${s[@]}"; do
    local u;    u=$( get_usage_short "${i}" );
    if [[ "$( in_string "|${t}|" "|${u}|" )" == "true" ]]; then
      echo "${i}"; return
    fi
  done
  echo ""
}