#!/usr/bin/env bash

#
# CONFIG
###################
_YAML_OUT_PREFIX="yaml"
_YAML_OUT_SEPARATOR="_"

#
# MODULE LOGIC
###################
#
# Read YAML into local variables
#
parse_yaml () {
  dump_method "$@"
  local source; local prefix; local separator;
  source="$1"; shift
  prefix=${1-"${_YAML_OUT_PREFIX}"}; shift
  separator=${1-"${_YAML_OUT_SEPARATOR}"}; shift
  [[ ! -z "${prefix}" ]] && prefix+="${separator}"
  local space='[[:space:]]*';
  local word='[a-zA-Z0-9_]*';
  local field=${special};
  tsed=$( sed \
        -ne "s|^\(${space}\):|\1|" \
        -e "s|^\(${space}\)\(${word}\)${space}:${space}[\"']\(.*\)[\"']${space}\$|\1${field}\2${field}\3|p" \
        -e "s|^\(${space}\)\(${word}\)${space}:${space}\(.*\)${space}\$|\1${field}\2${field}\3|p" \
        ${source} )
  tawk=$( echo "${tsed}" |
  awk -F${field} '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {
           vn=(vn)(vname[i])("'${separator}'")
         }
         printf("%s%s%s=\"%s\"\n", "'${prefix}'",vn, $2, $3);
      }
  }' )
  echo "${tawk// /%20}"
}
export -f parse_yaml
#
# Save local variables into YAML
#
save_yaml () {
  dump_method "$@"

}
export -f save_yaml

