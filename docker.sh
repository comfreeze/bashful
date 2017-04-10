#!/usr/bin/env bash

#
# CONFIG
###################

#
# MODULE LOGIC
###################
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
# Generate a docker compose command
assemble_compose () {
  echo $( assemble_command "${_CONFIG_COMPOSECMD}" "-f" $* )
}
export -f assemble_compose
# Generate a docker command
assemble_docker () {
  echo $( assemble_command "${_CONFIG_DOCKERCMD}" "-f" $* )
}
export -f assemble_docker

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
# Assemble base docker command
#
COMPOSE=$( assemble_compose ${___COMPOSE[@]} )
DOCKER=$( assemble_docker )
