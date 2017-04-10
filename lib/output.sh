#!/usr/bin/env bash

#
# Error message output
#
stderr() {
  >&2 printf '%b\n' "$*"
}
export -f stderr
stderrf() {
  local fmt; fmt=$1; shift
  >&2 printf ${fmt} "$*"
}
export -f stderrf
error () {
  code=$1; shift
  stderr $*
  exit $code
}
export -f error
columns () {
  col <<< "$*"
}
export -f columns
print_numeric_array () {
  local d; eval "d=( \"\${${1}[@]}\" )"
  local l; l=${2-"${1}"}
  verbose 0 "${l}=("
  for ITEM in "${d[@]}"; do
    verbosef 0 "\\t%s\\n" "${ITEM}"
  done
  verbose 0 ")"
}
export -f print_numeric_array