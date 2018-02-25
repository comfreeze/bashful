#!/usr/bin/env bash


#
# CONFIG
###################

#
# LIBRARIES
###################
require filesystem

#
# MODULE LOGIC
###################
#
# Read CSV into local variables
# Params
# filename - string - CSV raw filename
# column - integer - column index to slice
#
parse_csv () {
  dump_method "$@"
  local filename; filename=$1;    shift;
  local column;   column=${1--1}; shift;
  local csv; local csv_data;
  csv_data=()
  while IFS= read -r -a "csv"
  do
    if [ ${column} -gt 0 ]; then
      csv_data+=("${csv[${column}]}")
    else
      csv_data+=("${csv[*]}")
    fi
  done < "${filename}"
  echo "${csv_data[*]}"                                    # echo the result
}
export -f parse_csv
#
# Save local variables into YAML
#
save_ini () {
  dump_method "$@"

}
export -f save_ini