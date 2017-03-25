#!/usr/bin/env bash

#
# CONFIG
###################

#
# LIBRARIES
###################
require yaml
#
# Generating a temporary working file
#
working_file () {
  echo $( mktemp "${TMPDIR:-/tmp/}$(basename 0).XXXXXXXXXXXX" )
}
export -f working_file
#
# Generating a temporary working directory
#
working_directory () {
  echo $( mktemp -d "${TMPDIR:-/tmp/}$(basename 0).XXXXXXXXXXXX" )
}
export -f working_directory
#
# Process a list of files and append to array
#
get_files () {
  local files;  files=();
  local filter; filter=$1;    shift;
  local ext;    ext=$1;       shift;
  local file;   local filename;
  for file in "$*"; do
    if [[ -f ${file} ]] && [[ ${file:(-${#ext})} = "${ext}" ]]; then
      LEN=${#file}-${ext};  filename=${file:0:${LEN}}
      verbose 5 "Located matching file: ${filename}"
      files=( "${files[@]}" "${filename}=${file}" )
    fi
  done
}
export -f get_files
#
# Perform a series of operations on a given set
# of target directories
#
multidir () {
  local action; local target;
  action=$1;    shift
  for target in "$@"; do
    verbose 0 ${target}:
    ${action} "${target}"
  done
}
export -f multidir

read_file () {
  dump_method $*
  local filename;   filename=$1;    shift
  local start;      start=$1;       shift
  local finish;     finish=$1;      shift
  local section;    section="";     shift
  while read -r line; do
    [[ ${line} == ${start}* ]]      && printline="yes"
    [[ "${printline}" == "yes" ]]   && echo "${line}"
    [[ ${line} == ${finish}* ]]     && printline="no"
  done < "${filename}"
}
export -f read_file