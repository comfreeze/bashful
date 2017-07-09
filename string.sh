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
function real_length() {
  dump_method $*
    local LENGTH1; LENGTH1=$(echo "$1" | awk '{ print length }')
    local LENGTH2; LENGTH2=$(echo "${#1}")
    local LENGTH3; LENGTH3=$(expr length "${1}")
    # echo "$LENGTH1 - $LENGTH2 - $LENGTH3"
    if [ "$LENGTH1" -le "$LENGTH2" ] && [ "$LENGTH1" -le "$LENGTH3" ]; then
        echo "$LENGTH1";
    elif [ "$LENGTH2" -le "$LENGTH1" ] && [ "$LENGTH2" -le "$LENGTH3" ]; then
        echo "$LENGTH2";
    else
        echo "$LENGTH3";
    fi
}
export -f real_length

## Repeat Helper
function repeat_char() {
  local CHAR;  CHAR=${1-'\u2550'};
  local COUNT; COUNT=${2-1};
  local t;     t=$(printf "%-${COUNT}b" "${CHAR}");
  local c;     c=$(printf "%b" ${CHAR});
  echo "${t// /${c}}"
}
export -f repeat_char