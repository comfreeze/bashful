#!/usr/bin/env bash

#
# Array utilities
#
filter_array () {
  dump_method "$@"
  eval source=\( \"\${${1}[@]}\" \)
  shift
  selection=( $@ )
  for LINE in "${source[@]}"; do
    KEY="${LINE%%=*}"; VALUE="${LINE##*=}";
    for FILTER in ${selection[@]}; do
      if [[ "${FILTER}" = "${KEY}" ]]; then
        echo ${VALUE}
      fi
    done
  done
}
export -f filter_array
#
# CSV to array
#
csv_array () {
  dump_method "$@"
  echo $( explode_array "," $* )
}
export -f csv_array
#
# Delimiter to array
#
explode_array () {
  dump_method "$@"
  local delim; delim=$1; shift
  IFS="${delim}" read -a OUT <<< "$*"
  verb 5 dump_array_pretty OUT
  for I in "${OUT[@]}"; do
    printf '%s' "${I} "
  done
}
export -f explode_array
#
# Extract specific row
#
extract_row () {
  dump_method "$@"
  eval "target=( \"\${${1}[@]}\" )"; shift
  filter=$2; shift; len=${#filter};
  for T in "${TARGET[@]}"; do
    if [[ "${filter}" = "${T:0:${len}}" ]]; then
      echo "${T}"
    fi
  done
}