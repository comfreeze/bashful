#!/usr/bin/env bash

#
# CONFIG
###################
_V_DUMP=2
_V_DUMP_PRETTY=2
_V_DUMP_METHOD=1
#
# LIBRARIES
###################
require output
#
# Verbosity helpers
#
verbose() {
  if (( "${_V}" >= "$1" )); then
    shift; stderr $*
  fi
}
export -f verbose
verbosef() {
  if (( "${_V}" >= "$1" )); then
    shift; stderrf $*
  fi
}
export -f verbosef
verboses() {
  local level; level="%${_V}s"
  (( "${_V}" >= "1" )) && echo -n "-$( printf ${level} | tr " " "v" )"
}
export -f verboses
verb() {
  if (( "${_V}" >= "$1" )); then
    shift; $*
  fi
}
export -f verb
#
# Debugging helpers
#
dump () {
  verbose ${_V_DUMP} "\$$1=\"${!1}\""
}
export -f dump
dump_method () {
  verbose ${_V_DUMP_METHOD} "Method: ${FUNCNAME[1]} $*"
}
export -f dump_method
dump_array () {
  eval "verbose 2 \"$1=\"\${${1}[@]}\"\""
}
export -f dump_array
dump_array_pretty () {
  eval "target=( \"\${${1}[@]}\" )"
  verbose ${_V_DUMP_PRETTY} "$1=("
  for ITEM in "${target[@]}"; do
    verbosef ${_V_DUMP_PRETTY} '\t%s\n' "${ITEM}"
  done
  verbose ${_V_DUMP_PRETTY} ')'
}
export -f dump_array_pretty
dump_assoc_array () {
  eval "target=( \"\${${1}[@]}\" )"
  verbose ${_V_DUMP_PRETTY} "$1=("
  for ITEM in "${target[@]}"; do
    KEY="${ITEM%%=*}"; VALUE="${ITEM##*=}";
    verbose ${_V_DUMP_PRETTY} "${KEY}"
  done
  verbose ${_V_DUMP_PRETTY} ")"
}
export -f dump_assoc_array
#
# Verbosity parameter parsing and to-level config
# setters as well as access to help immediately so
# script will exit quickly.
#
while test $# -gt 0; do
  case "$1" in
    -v*)
      _V=$(grep -o "v" <<< "$1" | wc -l)
      echo "Verbosity: ${_V}"
      shift
    ;;
    -f|--fake)
      shift
      echo "Faking commands"
      _FAKE=true
    ;;
    -e|--env)
      shift
      _ENVFILE="$1"
      dump 1 _ENVFILE
      shift
    ;;
    *)
      OPTS=( "${OPTS[@]}" $1 )
      shift
    ;;
  esac
done
set -- ${OPTS[@]}
(( "${_V}" >= "1" )) && set +ex
(( "${_V}" >= "3" )) && set -e
(( "${_V}" >= "5" )) && set -ex
case "$-" in
    *i*)    _INTERACTIVE=true ;;
esac