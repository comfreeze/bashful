#!/usr/bin/env bash

#
# CONFIG
###################
__USE_DOCKER=false
DOCKER=""
COMPOSE=""

#
# LOAD LIBRARIES
###################
require utils

#
# MODULE LOGIC
###################
## Docker toggle helpers
function set__use_docker ()
{
  dump_method "$@"
  local value; value=${1-true}; shift
  __USE_DOCKER=${value}
}
export -f set__use_docker
function get__use_docker ()
{
  dump_method "$@"
  [[ ${__USE_DOCKER} ]] && return 0 || return 1
}
export -f get__use_docker
function use_docker ()
{
  return get__use_docker;
}
export -f use_docker
function set__docker ()
{
  dump_method "$@"
  [[ ${__USE_DOCKER} ]] && return 0 || return 1
}
export -f set__docker
## Runtime Configuration
function configure_docker ()
{
  dump_method "$@"
  # Assemble base docker and compose command
  COMPOSE=$( assemble_compose ${___COMPOSE[@]} )
  DOCKER=$( assemble_docker )
}
export -f configure_docker
## Generate a docker compose command
assemble_compose () {
  echo $( assemble_command "${_CONFIG_COMPOSECMD}" "-f" $* )
}
export -f assemble_compose
## Generate a docker command
assemble_docker () {
  echo $( assemble_command "${_CONFIG_DOCKERCMD}" "-f" $* )
}
export -f assemble_docker

#
# Shutdown, rebuild and run a custom command for the
# current ${COMPOSE} command string
#
reload () {
  ${COMPOSE} down
  ${COMPOSE} build
  ${COMPOSE} $@
}
export -f reload
reload_config () {
  name=$1
  dump 2 name
  eval data=\( \${${name}[@]} \)
  dump_array 2 data
  shift
  COMPOSE=$( assemble_compose ${data[@]} )
  reload $@
}
export -f reload_config
select_files () {
  echo $( filter_array __FILES $@ )
}
export -f select_files
select_repos () {
  echo $( filter_array __REPOS $@ )
}
export -f select_repos
select_containers () {
  echo $( filter_array __CONTAINERS $@ )
}
export -f select_containers

#
# ROUTING
###################
## Define Module Routes
route_load "$(cat <<ROUTE
[
	{
	  "namespace": "docker",
		"use": "--use-docker",
		"description": "Flag to enable general docker usage.",
		"callback": "set__use_docker",
		"priority": 999
	},
	{
	  "namespace": "docker",
		"use": "--docker (binary)",
		"description": "Specify the docker binary to use.",
		"callback": "set__docker",
		"priority": 999
	},
	{
	  "namespace": "docker",
		"use": "--compose (binary)",
		"description": "Specify the docker compose binary to use.",
		"callback": "set__compose",
		"priority": 999
	}
]
ROUTE
)"

#
# MODULE INIT
###################
configure_docker
