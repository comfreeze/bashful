#!/usr/bin/env bash

#
# String utilities
#
in_string () {
#  dump_method $*
  local t;  t=${1};  shift
  local s;  s=${1};  shift
  [[ "${s/${t}}" = "${s}" ]] && echo "false";
  echo "true";
}
export -f in_string
