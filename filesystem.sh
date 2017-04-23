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
  dump_method $*
  echo $( mktemp "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX" )
}
export -f working_file
#
# Generating a temporary working directory
#
working_directory () {
  dump_method $*
  echo $( mktemp -d "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX" )
}
export -f working_directory
#
# Process a list of files and append to array
#
get_files () {
  dump_method $*
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
  dump_method $*
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

## General Tools
function getrev() {
  dump_method $*
    local RESULT;
    RESULT=$(echo ${1} | cut -d${2} -f${3-1})
    echo ${RESULT}
}
export -f getrev;
## Grab the last string after /
function getdirname() {
  dump_method $*
    local TARGET;   TARGET=$1;
    local RESULT;
    RESULT=$(echo "${TARGET}" | cut -d \/ -f $(expr 1 + $(grep -o "/" <<< "${TARGET}" | wc -l)))
    echo ${RESULT}
}
export -f getdirname;
## Download remote file
function getfile() {
  dump_method $*
    local TARGET;   TARGET="$1"
    wget -q -N "${TARGET}"
}
export -f getfile;
## Mirror a remote directory
function getremotedir() {
  dump_method $*
    local TARGET;   TARGET="$1"
    local EXCLUDES; EXCLUDES="$2"
    local ex;
    for EXCLUDE in ${EXCLUDES[@]}; do
        ex="$ex -R ${EXCLUDE}";
    done
    wget -q -N -mk -w 3 -r -np -nH --cut-dirs=10 ${ex} "${URL}"
}
export -f getremotedir;
## Output Tools
## Create or change to directory
function check_directory() {
  dump_method $*
    local ROOT;   ROOT="$1"
    local TARGET; TARGET="$2"
    local DIR;    DIR=$(getdirname ${ROOT})
#    box_line "Parsing ${DIR}"
    if [ ! "${TARGET}" == "${DIR}" ]; then
        if [ ! -d "${TARGET}" ]; then
#            box_line "Creating ${TARGET}"
            mkdir -p "${TARGET}"
            chmod a+r "${TARGET}"
        fi
#        box_line "Entering ${TARGET}"
        cd "${TARGET}"
    fi
}
export -f check_directory;
## Manipulation Helpers
function find_replace() {
  dump_method $*
    local TARGET;       TARGET=$1;
    local REPLACEMENT;  REPLACEMENT=$2;
    find . -type f -exec sed -i -e "s/${TARGET//\//\\\/}/${REPLACEMENT//\//\\\/}/g" {} \;
}
## Expose custom functions
export -f find_replace;