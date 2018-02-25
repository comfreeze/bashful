#!/usr/bin/env bash

#
# CONFIG
###################
_INI_OUT_PREFIX="ini"
_INI_SECTION_PREFIX="cfg.section."

#
# MODULE LOGIC
###################
#
# Read YAML into local variables
#
parse_ini () {
    fixed_file=$(cat $1 | sed 's/ = /=/g')              # fix ' = ' to be '='
    IFS=$'\n' && ini=( $fixed_file )                    # convert to line-array
    ini=( ${ini[*]//;*/} )                              # remove comments
    ini=( ${ini[*]/#[/\}$'\n'${_INI_SECTION_PREFIX}} )  # set section prefix
    ini=( ${ini[*]/%]/ \(} )                            # convert text2function (1)
    ini=( ${ini[*]/=/=\( } )                            # convert item to array
    ini=( ${ini[*]/%/ \)} )                             # close array parenthesis
    ini=( ${ini[*]/%\( \)/\(\) \{} )                    # convert text2function (2)
    ini=( ${ini[*]/%\} \)/\}} )                         # remove extra parenthesis
    ini[0]=''                                           # remove first element
    ini[${#ini[*]} + 1]='}'                             # add the last brace
    echo "${ini[*]}"                                    # eval the result
}
export -f parse_ini
#
# Save local variables into YAML
#
save_ini () {
  dump_method "$@"

}
export -f save_ini
