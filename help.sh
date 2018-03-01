#!/usr/bin/env bash

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
## Help Entrypoint
function help_usage ()
{
  dump_method "$@"
}
## Usage List
function usage_list ()
{
  dump_method "$@"
  local usage="`echo "${__ACTIVE_ROUTES}" | jq -r '[.routes[] | {namespace, use, description}] | group_by(.namespace) | map({(.[0].namespace): .})'`"
  local namespaces=( `echo "${usage}" | jq -c -r ' .[] | keys | add '` )
  for namespace in "${namespaces[@]}"; do
    routes="$(echo "${usage}" | jq -r ".[] | objects | select(has(\"${namespace}\")).${namespace}")"
    local count;   count=`echo "${routes}" | jq '. | length' 2>&1`;
    local i=0;
    echo " ${namespace}:"
    printf " %-35s | %s\n" "USE" "DESCRIPTION"
    repeat_char "=" 80
    while [[ ${i} -lt ${count} ]]; do
      route="`echo "${routes}" | jq ".[$i]" 2>&1`"
      use=$( echo "${route}" | jq -r '.use' )
      description=$( echo "${route}" | jq -r '.description' )
      printf " %-35s | %s\n" "${use}" "${description}"
      (( i+=1 ));
    done
    echo
  done
}
export -f usage_list
## Usage List Namespace
function usage_namespace_list ()
{
  dump_method "$@"
  local search;   search="$1";
  local usage="`echo "${__ACTIVE_ROUTES}" | jq -r '[.routes[] | {namespace, use, description}] | group_by(.namespace) | map({(.[0].namespace): .})'`"
  routes="$(echo "${usage}" | jq -r ".[] | objects | select(has(\"${search}\")).${search}")"
  local count;   count=`echo "${routes}" | jq '. | length' 2>&1`;
  local i=0;
  echo " ${namespace}:"
  printf " %-35s | %s\n" "USE" "DESCRIPTION"
  repeat_char "=" 80
  while [[ ${i} -lt ${count} ]]; do
    route="`echo "${routes}" | jq ".[$i]" 2>&1`"
    use=$( echo "${route}" | jq -r '.use' )
    description=$( echo "${route}" | jq -r '.description' )
    printf " %-35s | %s\n" "${use}" "${description}"
    (( i+=1 ));
  done
  echo
}
## Usage Entrypoint
function usage ()
{
  dump_method "$@"
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
# ROUTING
###################
## Help Commands
route_load "$(cat <<ROUTE
[
  {
    "namespace": "help",
    "use": "-h|--help|help",
    "description": "Display help",
    "callback": "help_usage",
    "priority": 1
  },
  {
    "namespace": "help",
    "use": "--list-commands",
    "description": "Display all registered command usage.",
    "callback": "usage_list",
    "priority": 1
  },
  {
    "namespace": "help",
    "use": "--namespace-commands (namespace)",
    "description": "Display all registered command usage.",
    "callback": "usage_list",
    "priority": 1
  }
]
ROUTE
)"