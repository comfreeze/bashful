#!/usr/bin/env bash

#
# String utilities
#
in_string () {
  dump_method $*
  [[ "${2/${1}}" = "${2}" ]] && echo "false";
  echo "true";
}
export -f in_string
