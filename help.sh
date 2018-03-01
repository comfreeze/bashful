#!/usr/bin/env bash

#
# CONFIG
###################

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
  local usage="$( json_group_objects __ACTIVE_ROUTES "routes" "namespace" )"
  local namespaces=( $( json_get_keys usage ) )
  for namespace in "${namespaces[@]}"; do
    usage_namespace_list "${namespace}"
  done
}
export -f usage_list
## Usage List Namespace
function usage_namespace_list ()
{
  dump_method "$@"
  local search;   search="$1";
  local usage="$( json_group_objects __ACTIVE_ROUTES "routes" "namespace" )"
  routes="$( json_get_object "${namespace}" usage )"
  local count;   count=$( json_array_length routes );
  local i=0;
  echo " ${namespace}:"
  printf " %-35s | %s\n" "USE" "DESCRIPTION"
  repeat_char "=" 80
  while [[ ${i} -lt ${count} ]]; do
    route="$( json_get_array_item "$i" routes )"
    use=$( json_get_key "use" route )
    description=$( json_get_key "description" route )
    printf " %-35s | %s\n" "${use}" "${description}"
    (( i+=1 ));
  done
  echo
}

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
    "pattern": "--namespace-commands",
    "use": "--namespace-commands (namespace)",
    "description": "Display all registered command usage.",
    "callback": "usage_namespace_list",
    "priority": 1
  }
]
ROUTE
)"