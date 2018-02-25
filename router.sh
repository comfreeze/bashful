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
  "visible: "true",
  "priority": 0
}
ROUTE

__ACTIVE_ROUTES="{}"
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
  local routes;  routes="$1";   shift
  dump routes
  dprint `echo "${routes}" | jq '. | length' 2>&1`
}
export -f route_load
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
#  options  - array  - One or more custom parameters
#
route_list () {
  dump_method "$@"
  local endpoint; endpoint="$1";  shift
  local options;  options="$1";   shift

}
export -f route_list
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

}
export -f route