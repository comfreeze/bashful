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