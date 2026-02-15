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

__ACTIVE_ROUTES='{"routes":[]}'
__ACTIVE_NAMESPACE='{}'
__ACTIVE_ROUTE='{}'
declare -a _ROUTER_ENDPOINTS
declare -a _ROUTER_PARAMS

#
# LIBRARIES
###################
require json
require string

#
# MODULE LOGIC
###################
## Routing variable helpers
function set__active_routes ()
{
  dump_method "$@"
  __ACTIVE_ROUTES="$1"
}
function get__active_routes ()
{
  dump_method "$@"
  echo "${__ACTIVE_ROUTES}"
}
function set__active_namespace ()
{
  dump_method "$@"
  __ACTIVE_NAMESPACE="$1"
}
function get__active_namespace ()
{
  dump_method "$@"
  echo "${__ACTIVE_NAMESPACE}"
}
function set__active_route ()
{
  dump_method "$@"
  __ACTIVE_ROUTE="$1"
}
function get__active_route ()
{
  dump_method "$@"
  echo "${__ACTIVE_ROUTE}"
}
## New route definitions
#
# Params:
#  options  - array    - One or more custom parameters
#  callback - function - Receiver function for events to endpoint(s)
#
function route_create ()
{
  dump_method "$@"
  local options;  options="$1";   shift
  local callback; callback="$1";  shift
  dump options
  dump callback

}
## New route definitions
#
# Params:
#  routes   - array    - One or more custom parameters
#  endpoint - array    - One or more endpoint patterns to match
#  callback - function - Receiver function for events to endpoint(s)
#
function route_load ()
{
  dump_method "$@"
  local route;  route="$1";   shift
  local pattern;
  local use;
  if [[ "${route:0:1}" == "[" ]]; then
    route_load_array "${route}"
  elif [[ "${route:0:1}" == "{" ]]; then
    route=$( json_merge_objects ROUTE_TEMPLATE route )
    pattern=$( json_get_key pattern route )
    use=$( json_get_key use route )
    if [ -z "${pattern// }" ]; then
      route=$( json_set_key pattern use route )
    fi
    __ACTIVE_ROUTES=$( json_append_object routes __ACTIVE_ROUTES route )
  fi
}
## New route definitions - Array format
#
# Params:
#  routes   - array    - One or more custom parameters
function route_load_array ()
{
  dump_method "$@"
  local routes;  routes="$1";   shift
  local count;   count=$( json_array_length routes );
  local i=0;
  while [[ ${i} -lt ${count} ]]; do
    route="`echo "${routes}" | jq ".[$i]" 2>&1`"
    route_load "${route}"
    (( i+=1 ));
  done
}
## Extend route definition
#
# Params:
#  endpoint - string   - Specific endpoint patterns to match
#  callback - function - Receiver function for events to endpoint(s)
#  options  - array    - One or more custom parameters
#
function route_extend ()
{
  dump_method "$@"
  local endpoint; endpoint="$1";  shift
  local callback; callback="$1";  shift
  local options;  options="$1";   shift

}
## Clear Routes
#
# Params:
#  endpoint - array  - One or more endpoint patterns to match
#
function route_delete ()
{
  dump_method "$@"
  local endpoint; endpoint="$1";  shift

}
## List Routes
#
# Params:
#  endpoint - array  - One or more endpoint patterns to match
#
function route_list ()
{
  dump_method "$@"
  dprint "${__ACTIVE_ROUTES}"
}
## Match Route
#
# Params:
#  options  - array  - One or more custom parameters
#
function route_match ()
{
  dump_method "$@"
  local search;  search="$1"; shift
  local route;
  info "Searching Usages: ${search}"
  route=$( json_value_search "routes" "use" "${search}" __ACTIVE_ROUTES )
  if [[ -z "${route}" ]]; then
    info "Searching Patterns: ${search}"
    route=$( json_value_search "routes" "pattern" "${search}" __ACTIVE_ROUTES )
  fi
  local pattern; pattern=$( json_get_key pattern route )
  local IFS='|'
  local p
  for p in ${pattern}; do
    case "${search}" in
      ${p})
        echo "${route}"
        return
        ;;
    esac
  done
}
## Global Routing Parameters
#
function route_param ()
{
  dump_method "$@"
  local param;    param="$1";     shift
  local values;   values="$1";    shift
  local rules;    rules="$1";     shift

}
## Router Entry-point
#
# Params:
#  * - Any parameters
#
function route ()
{
  dump_method "$@"
  while [[ "$#" -gt 0 ]]; do
    route="$( route_match "$@" )"
    usage=$( echo "${route}" | jq -r '.use' )
    callback=$( echo "${route}" | jq -r '.callback' )
    if [[ ! -z "${callback}" ]]; then
      shift
      ${callback} $@
      unset callback
      ## Clear associated parameters
      char_count ' ' "${usage}"
      param_count=$?
      ## Loop to shift count of spaces
      while [[ "${param_count}" > 0 ]]; do
        shift
        (( param_count-=1 ))
      done
    else
      ## Remove current option if no route matched
      warn "No route match found: $1"
      shift
    fi
  done
}

#
# MODULE EXPORTS
###################
export -f set__active_routes
export -f get__active_routes
export -f set__active_namespace
export -f get__active_namespace
export -f set__active_route
export -f get__active_route
export -f route_create
export -f route_load
export -f route_load_array
export -f route_extend
export -f route_delete
export -f route_list
export -f route_match
export -f route_param
export -f route