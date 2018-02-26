#!/usr/bin/env bash

#
# CONFIG
###################
read -r -d '' ROUTE_TEMPLATE <<ROUTE
{
  "namespace": "user",
  "pattern": "",
  "use": "",
  "description": "",
  "callback": "",
  "visible": "true",
  "priority": 100
}
ROUTE

__ACTIVE_ROUTES="{\"routes\":[]}"
declare -a _ROUTER_ENDPOINTS
declare -a _ROUTER_PARAMS

#
# LIBRARIES
###################
require json
#require actions
#require params

#
# UPSTREAM REFERENCES
###################
#
# ACTIONS HELPERS
#
# clear_actions - Clear current array collections
# config_actions - Read defined parameters
# config_actions_bash - Read defined parameters
# config_actions_yaml64 - Base64 decode input before processing
# config_actions_yaml - Read a YAML string for actions
# eval_actions - Use defined parameters to set globals
#
# PARAMETER HELPERS
#
# clear_params - Clear parameters
# config_params - Read defined parameters
# config_params_bash
# config_params_yaml64 - Base64 decode input before processing
# config_params_yaml - Read a YAML string for params
# eval_params - Use defined parameters to set globals

#
# MODULE LOGIC
###################
#
# New route definitions
#
# Params:
#  options  - array    - One or more custom parameters
#  callback - function - Receiver function for events to endpoint(s)
#
route_create () {
  dump_method "$@"
  local options;  options="$1";   shift
  local callback; callback="$1";  shift
  dump options
  dump callback

}
export -f route_create
#
# New route definitions
#
# Params:
#  routes   - array    - One or more custom parameters
#  endpoint - array    - One or more endpoint patterns to match
#  callback - function - Receiver function for events to endpoint(s)
#
route_load () {
  dump_method "$@"
  local route;  route="$1";   shift
  local pattern;
  local use;
  if [[ "${route:0:1}" == "[" ]]; then
    route_load_array "${route}"
  elif [[ "${route:0:1}" == "{" ]]; then
    route=$( echo "${ROUTE_TEMPLATE}" "${route}" | jq -s 'reduce .[] as $item ({}; . * $item)' 2>&1 )
    pattern=$( echo "${route}" | jq -r '.pattern' )
    use=$( echo "${route}" | jq -r '.use' )
    if [ -z "${pattern// }" ]; then
      route=$( echo "${route}" | jq -r ".pattern = \"${use}\"" )
    fi
    __ACTIVE_ROUTES=$( echo "${__ACTIVE_ROUTES}" | jq -r ".routes[.routes | length] |= . + ${route}" )
  fi
}
export -f route_load
#
# New route definitions - Array format
#
# Params:
#  routes   - array    - One or more custom parameters
route_load_array () {
  dump_method "$@"
  local routes;  routes="$1";   shift
  dump routes
  dump ROUTE_TEMPLATE
  local count;   count=`echo "${routes}" | jq '. | length' 2>&1`;
  local i=0;
  while [[ ${i} -lt ${count} ]]; do
    route="`echo "${routes}" | jq ".[$i]" 2>&1`"
    dump route
    route_load "${route}"
    (( i+=1 ));
  done
}
export -f route_load_array
#
# Extend route definition
#
# Params:
#  endpoint - string   - Specific endpoint patterns to match
#  callback - function - Receiver function for events to endpoint(s)
#  options  - array    - One or more custom parameters
#
route_extend () {
  dump_method "$@"
  local endpoint; endpoint="$1";  shift
  local callback; callback="$1";  shift
  local options;  options="$1";   shift

}
export -f route_extend
#
# Clear Routes
#
# Params:
#  endpoint - array  - One or more endpoint patterns to match
#
route_delete () {
  dump_method "$@"
  local endpoint; endpoint="$1";  shift

}
export -f route_delete
#
# List Routes
#
# Params:
#  endpoint - array  - One or more endpoint patterns to match
#
route_list () {
  dump_method "$@"
  dprint "${__ACTIVE_ROUTES}"
}
export -f route_list
#
# Match Route
#
# Params:
#  options  - array  - One or more custom parameters
#
route_match () {
  dump_method "$@"
  local endpoint; endpoint="$1";  shift
  local options;  options="$1";   shift

}
export -f route_match
#
# Global Routing Parameters
#
route_param () {
  dump_method "$@"
  local param;    param="$1";     shift
  local values;   values="$1";    shift
  local rules;    rules="$1";     shift

}
export -f route_param
#
# Router Entry-point
#
# Params:
#  * - Any parameters
#
route () {
  dump_method "$@"
  while [[ "$#" -gt 0 ]]; do
    route=$( echo "${__ACTIVE_ROUTES}" | jq --arg search "$1" -r '.routes[] | select(.pattern | contains($search))' )
    if [[ -z "${route}" ]]; then
      route=$( echo "${__ACTIVE_ROUTES}" | jq --arg search "$1" -r '.routes[] | select(.use | contains($search))' )
    fi
    callback=$( echo "${route}" | jq -r '.callback' )
    `${callback} $@`
    shift
  done
}
export -f route