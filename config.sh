#!/usr/bin/env bash

#
# CONFIG
###################
declare -a _PARAMS
declare -a _ACTIONS
declare -a _CP
declare -a _CV
declare -a _CT
declare -a _CD
_CONFIG=""
__CONFIG_WORKING__=""

#
# LIBRARIES
###################
require array

#
# MODULE LOGIC
###################
#
# Clear config
#
clear_configs () {
  dump_method $*
  unset _CONFIG:    unset __CONFIG_WORKING__;
  unset _CP;    unset _CV;  unset _CT;  unset _CD;
}
#
# Read defined config
#
load_config () {
  dump_method $*
  case $1 in
    file)   shift;  load_config_file "$*"     ;;
    yaml64) shift;  load_config_yaml64 "$*"   ;;
    yaml)   shift;  load_config_yaml "$*"     ;;
    *)              load_config_bash "$*"     ;;
  esac
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
# Configuration source loader
#
load_config_file () {
  if [ -f "$1" ]; then
    verbose 1 "Loading configuration file: ${1}"
    source "$1"
  fi
}
export -f load_config_file
load_config_bash () {
  dump_method $*
  clear_configs
  eval "__C=( \"\${${1}[@]}\" )"; shift
  local e;
  for PARAM in "${__C[@]}"; do
    e=( $( explode_array = "${PARAM// /${field}}" ) )
    _CP=( "${_CP[@]}" "${e[0]}" );
    _CV=( "${_CV[@]}" "${e[1]}" );
    _CT=( "${_CT[@]}" "${e[2]//${field}/ }" );
    _CD=( "${_CD[@]}" "${e[3]//${field}/ }" );
  done
}
export -f load_config_bash
#
# Base64 decode input before processing
#
load_config_yaml64 () {
  dump_method $*
  __CONFIG_WORKING__="$( base64_decode ${!1} )";
  echo "$( load_config_yaml __CONFIG_WORKING__ )"
}
#
# Read a YAML string for configs
#
load_config_yaml () {
  dump_method $*
  local data;       eval "data=\"\${${1}}\""
  local prefix;     prefix=${2-""}
  local separator;  separator=${3-"_"}
  local TEMP_FILE;  TEMP_FILE=$( working_file )
  echo "${data}" > "${TEMP_FILE}"
  __CONFIG_WORKING__=( $( parse_yaml "${TEMP_FILE}" "${prefix}" "${separator}" ) )
  for ITEM in "${__CONFIG_WORKING__[@]}"; do
    echo "${ITEM}"
#    config=$( echo "${ITEM%_*}" );
#    type=$( echo "${ITEM##*_}" | cut -d"=" -f1 );
#    name="${ITEM%=*//${config}/}";  name="${name//${type}/}";
#    value="${ITEM##*=}";            value="${value//%20/ }"
#    case "${type}" in
#      flags)        _CP=( "${_CP[@]}" "${value}" )  ; _PARAMS=( "${_PARAMS[@]}" "${name//params_/}" )    ;;
#      keywords)     _CP=( "${_CP[@]}" "${value}" )  ; _ACTIONS=( "${_ACTIONS[@]}" "${name//actions_/}" ) ;;
#      type)         _CT=( "${_CT[@]}" "${value}" )  ;;
#      target)       _CV=( "${_CV[@]}" "${value}" )  ;;
#      description)  eval "${ITEM}"                  ;;
#    esac
  done
  rm -rf ${TEMP_FILE}
}
#
# Use defined config to set globals
#
eval_configs () {
  dump_method $*
  local test; local var; local type; local pt;
  for up in $*; do
    for pi in $( config_count ); do
      config="${_CP[${pi}]}"; var="${_CV[${pi}]}"; type="${_CT[${pi}]}";
      pt=( $( explode_array "|" "${config}" ) )
      for p in "${pt[@]}"; do
        if [[ "${up}" == "${p}" ]]; then
          verbose 1 "Matched ${config}"
          shift
          case "${type}" in
            boolean)
              eval "export ${var}=true"
              dump ${var}
              ;;
            array)
              eval "export ${var}=( \"\${${var}[@]}\" \"$1\" )"
              dump ${var}
              shift
              ;;
            function|method)
              shift
              eval "${method} $*"
              exit $?
              ;;
            *|string)
              eval "export ${var}=$1"
              dump ${var}
              shift
              ;;
          esac
        fi
      done
    done
  done
}
export -f eval_configs
config_count () {
  dump_method $*
  local i; i=0
  while [ "$i" -lt "${#_CP[@]}" ]; do
    echo -n "${i} "; i=$[$i+1];
  done
}
export -f config_count

action_count () {
  dump_method $*
  local i; i=0
  while [ "$i" -lt "${#_ACTIONS[@]}" ]; do
    echo -n "${i} "; i=$[$i+1];
  done
}
export -f action_count
param_count () {
  dump_method $*
  local i; i=0
  while [ "$i" -lt "${#_PARAMS[@]}" ]; do
    echo -n "${i} "; i=$[$i+1];
  done
}
export -f param_count
#
# Parameter parsing
#
#load_config PARAMS
