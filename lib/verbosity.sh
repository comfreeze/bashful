#!/usr/bin/env bash

require output
#
# Verbosity helpers
#
verbose() {
  if (( "${_V}" >= "$1" )); then
    shift; stderr $*
  fi
}
verbosef() {
  if (( "${_V}" >= "$1" )); then
    shift; stderrf $*
  fi
}
export -f verbose
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
  verbose 2 "\$$1=\"${!1}\""
}
export -f dump
dump_method () {
  verbose 4 "Method: ${FUNCNAME[1]} $*"
}
export -f dump_method
dump_array () {
  eval "verbose 2 \"$1=\"\${${1}[@]}\"\""
}
export -f dump_array
dump_array_pretty () {
  eval "target=( \"\${${1}[@]}\" )"
  verbose 1 "$1=("
  for ITEM in "${target[@]}"; do
    verbosef 1 '\t%s\n' "${ITEM}"
  done
  verbose 1 ')'
}
export -f dump_array_pretty
dump_assoc_array () {
  eval "target=( \"\${${1}[@]}\" )"
  verbose 1 "$1=("
  for ITEM in "${target[@]}"; do
    KEY="${ITEM%%=*}"; VALUE="${ITEM##*=}";
    verbose 1 "${KEY}"
  done
  verbose 1 ")"
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