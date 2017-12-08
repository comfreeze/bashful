#!/usr/bin/env bash

#
# CONFIG
###################
_TABLE_OPTS="allbox;"
_TABLE_CELL="lw(2)"
_TABLE_FMT="utf8"

#
# MODULE LOGIC
###################
# Error message output
function stderr ()
{
  >&2 printf '%b\n' "$*"
}
export -f stderr
# Formatted error message output
function stderrf ()
{
  local fmt; fmt=$1; shift
  >&2 printf ${fmt} "$*"
}
export -f stderrf
# Regular error output
function error ()
{
  code=$1; shift
  stderr $*
  exit ${code}
}
export -f error
# Audible alert output
function bell ()
{
  tput bel
}
export -f bell
# Column output helper
function columns ()
{
  col <<< "$*"
}
export -f columns
# Numeric array output helper
function print_numeric_array ()
{
  local d; eval "d=( \"\${${1}[@]}\" )"
  local l; l=${2-"${1}"}
  verbose 0 "${l}=("
  for ITEM in "${d[@]}"; do
    verbosef 0 "\\t%s\\n" "${ITEM}"
  done
  verbose 0 ")"
}
export -f print_numeric_array
# Table assistant
function print_table ()
{
  local data;   eval data=( \"\${${1}[@]}\" );  shift
  local tab;    tab=${1-';'};                   shift
  local cells;  cells='';                       shift
  format=".TS\n"
  format+="tab(${tab}) ${_TABLE_OPTS}\n"
  colcount=( $( echo "${data[0]}" | awk -F"${tab}" '{print NF-1}' ) )
  colcount=${colcount[0]}
  dump colcount
  colcount=$((colcount+1))
  [[ "${cells}" == "" ]] && cells="$( repeat_string "${_TABLE_CELL}" ${colcount} )"
  dump cells
  format+="${cells}"
  format+=".\n"
  for line in "${data[@]}"; do
#    line="$( echo "${line}" | sed -e 's/(\\[n])/.br/g' )"
    format+="${line}\n"
  done
  format+=".TE"
  echo "$( echo -ne "${format}" | groff -t -T${_TABLE_FMT} | sed '/^$/d' )"
}