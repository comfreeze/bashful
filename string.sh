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

## Repeat Helper
function repeat_char() {
  local CHAR;  CHAR=${1-'\u2550'};
  local COUNT; COUNT=${2-1};
  local t;     t=$(printf "%-${COUNT}b" "${CHAR}");
  local c;     c=$(printf "%b" ${CHAR});
  echo "${t// /${c}}"
}
export -f repeat_char