#!/usr/bin/env bash

#
# Configuration source loader
#
load_config () {
  if [ -f "$1" ]; then
    verbose 1 "Loading configuration file: ${1}"
    source "$1"
  fi
}
export -f load_config
save_local() {
  [[ ! -f "${_ENVFILE}" ]] && echo "#!/usr/bin/env bash" > "${_ENVFILE}"
  echo "Do you wish to save this to ${_ENVFILE}? [Y/n]:"; read choice
  case "${choice}" in
    y|yes)
      verbose 3 "Writing value of $1 to ${_ENVFILE}"
      echo "$1" >> "${_ENVFILE}"
    ;;
  esac
}
export -f save_local

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