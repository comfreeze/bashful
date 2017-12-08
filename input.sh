#!/usr/bin/env bash

#
# CONFIG
###################

#
# LIBRARIES
###################

#
# MODULE LOGIC
###################
#
# Basic user input
#
read_input()
{
  dump_method $*
  local target; target=${1-"USER_INPUT"};   shift;
  local label;  label=${1-"${target}:"};    shift;
  local prompt; prompt=${1-""};             shift;
  local hint;   hint=${1-""};               shift;
#  verbose 0 "${label}";
  [[ ! -z "${hint}" ]] && prompt+="[${hint}]";
  set +e
  read -a "__INPUT__" -p "${label} "
  verbosee 4 "${target}=\"${__INPUT__[@]}\""
}
export -f read_input
#
# Basic user input
#
readline_input()
{
  dump_method $*
  local target; target=${1-"USER_INPUT"};   shift;
  local label;  label=${1-"${target}:"};    shift;
  local prompt; prompt=${1-""};             shift;
  local hint;   hint=${1-""};               shift;
#  verbose 0 "${label}";
  [[ ! -z "${hint}" ]] && prompt+="[${hint}]";
  set +e
  read -e -a "__INPUT__" -p "${label} "
  verbosee 4 "${target}=\"${__INPUT__[@]}\""
}
export -f read_input
#
# Simple Yes/No
#
yes_no()
{
  dump_method $*
  local target; target=${1-"USER_INPUT"};   shift;
  local label;  label=${1-"${target}:"};    shift;
  local prompt; prompt=${1-""};             shift;
  read_input TEMP "${label}" "${prompt}" "Y/n"
  case "${TEMP:0:1}" in
    Y|y)    eval "${target}=true"   ;;
    *)      eval "${target}=false"  ;;
  esac
}
#
# Simple Yes/No that uses return codes
#
yes_no_return()
{
  dump_method $*
  local label;  label=${1-"YES or NO?"};    shift;
  local prompt; prompt=${1-""};             shift;
  read_input TEMP "${label}" "${prompt}" "Y/n"
  case "${TEMP:0:1}" in
    Y|y)    return 0    ;;
  esac
  return 1
}
#
# Numeric list of options
#
numeric_list()
{
  dump_method $*
  local choices;    eval "choices=( \"\${${1}[@]}\" )"; shift;
  local target;     target=${1-"USER_INPUT"};           shift;
  local label;      label=${1-"${target}:"};            shift;
  local prompt;     prompt=${1-""};                     shift;
  local hint;       hint="1-${#choices[@]}";            shift;
  print_numeric_array choices
  read_input TEMP "${label}" "${prompt}" "${hint}"
  TEMP=$(($TEMP-1))
  verbosee 3 "${target}=\"${choices[${TEMP}]}\""
}
#
# Raw user input line
#
input_line()
{
  dump_method $*
  local target;     target=${1-"USER_INPUT"};           shift;
  local label;      label=${1-"${target}:"};            shift;
  local prompt;     prompt=${1-""};                     shift;
  local default;    default=${1-""};                    shift;
  read_input "${target}" "${label}" "${prompt}"
}
#
# Smart user input line
#
input_readline()
{
  dump_method $*
  local target;     target=${1-"USER_INPUT"};           shift;
  local label;      label=${1-"${target}:"};            shift;
  local prompt;     prompt=${1-""};                     shift;
  local default;    default=${1-""};                    shift;
  readline_input "${target}" "${label}" "${prompt}"
}
#
# Break-point continue prompt
#
confirm ()
{
  dump_method $*
  local prompt;     prompt=${1-""};                     shift;
  read -p "${prompt} " -n 1 -r
}