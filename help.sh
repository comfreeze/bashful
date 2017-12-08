#!/usr/bin/env bash

#
#
# CONFIG
###################
_PREFIX_USAGE="usage_"
_GROUP_FORMAT='  %-18s : %-18s : %s\n'
declare -a __WORKING_ARRAY
declare -a _USAGE_EXCLUDES

#
# LIBRARIES
###################
require utils
require array

#
# CUSTOM LOGIC
###################
usage_command ()
{
  dump_method $*
  cat << EOF
${USAGE_TITLE}

 $( basename $0 ) $*
EOF
}
export -f usage_command

usage_group ()
{
  dump_method $*
  local title;  title=$1;   shift
  local prefix; prefix=$1;  shift
  local items;  items=( $( get_functions "${prefix}" ) )
  echo "${title}"
  for i in "${items[@]}"; do
    local u;    u=$( get_usage_short "$i" );
    local d;    d=$( get_description "$i" );
    if [[ "${#u}" > "0" ]]; then
      printf "${_GROUP_FORMAT}" "${i}" "${u//\|/,}" "${d}"
    fi
  done
}
export -f usage_group

usage_options ()
{
  dump_method $*
  usage_group " FLAGS:" "${_PREFIX_PARAM}"
}
export -f usage_options

usage_actions ()
{
  dump_method $*
  usage_group " ACTIONS:" "${_PREFIX_ACTION}"
}
export -f usage_actions

get_usage ()
{
#  dump_method $*
  echo "$( get_function_output "${_PREFIX_USAGE}$*" )"
}
get_usage_short ()
{
#  dump_method $*
  local d; d=( $( get_function_output "${_PREFIX_USAGE}$*" ) )
  [[ "${d[0]}" == "" ]] && d="$*"
  echo "${d[0]}"
}
get_description ()
{
#  dump_method $*
  echo "$( get_function_output "${_PREFIX_DESCRIPTION}$*" )"
}

usage_details ()
{
  dump_method $*
  cat << EOF
EOF
}

usage_advanced ()
{
  dump_method $*
  cat << EOF
EOF
}
_load_usage ()
{
  dump_method $*
  level=$1; shift
  usage=$1; shift
#  eval "verb ${level} usage_${usage} $*"
  echo "$( usage_${usage} $* )"
}
_load_help ()
{
  level=$1; shift
  usage=$1; shift
#  eval "verb ${level} usage_${usage} $*"
  echo "$( help_${usage} $* )"
}
#
# Capture defined usage functions
#
_USAGE_FUNCS=( $( get_functions usage_ ) )
#
# Usage information
#
usage ()
{
  dump_method $*
  for FUNC in "${_USAGE_FUNCS[@]}"; do
    if [[ "${FUNC}" = "$2" ]]; then
      local name; name=$2; shift
      _load_usage 0 command "$( get_usage "${name}" )"
      _load_help 0 ${name} $*
      exit 0
    fi
  done
  case "$2" in
    list)
      local t;
      t=( $( get_functions "${_PREFIX_ACTION}" ) ); _V_DUMP_PRETTY=0 dump_array_pretty t "Actions"
      t=( $( get_functions "${_PREFIX_PARAM}" ) ); _V_DUMP_PRETTY=0 dump_array_pretty t "Params"
    ;;
    actions)
      _load_usage 0 actions
    ;;
    params)
      _load_usage 0 options
    ;;
    *)
      _load_usage 0 command "(options) [actions] (parameters)"
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
      __WORKING_ARRAY+=( $1 )
      shift
    ;;
  esac
done
set -- ${__WORKING_ARRAY[@]}
