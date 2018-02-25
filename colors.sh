#!/usr/bin/env bash

#
# CONFIG
###################
_DEFAULT_COLOR_TOOL="ascii"
## Color Settings Holder
_FG=${FG-2};    _BG=${BG-0};
## State Settings
_BB=${BASHFUL_BOLD-"false"}
## Color References
_BLK=0; _RED=1; _GRN=2; _YLW=3;
_BLU=4; _PUR=5; _CYN=6; _WHT=7;
## ASCII Code Holder
__ASCII=''
## Color References
RESET=
FG_BLK=; BG_BLK=;
FG_RED=; BG_RED=;
FG_GRN=; BG_GRN=;
FG_YLW=; BG_YLW=;
FG_BLU=; BG_BLU=;
FG_PUR=; BG_PUR=;
FG_CYN=; BG_CYN=;
FG_WHT=; BG_WHT=;

#
# CUSTOM LIBRARIES
###################
require ascii

#
# MODULE LOGIC
###################
#
# Register color variables
#
register_colors ()
{
  case $1 in
    tput)   shift;  register_colors_tput "$*"   ;;
    *)              register_colors_ascii "$*"  ;;
  esac
}
export -f register_colors
#
# tput based colors
#
register_colors_tput ()
{
  dump_method "$@"
  RESET=`tput sgr0`
  # Foreground ------------------ Background
  FG_BLK=`tput setaf ${_BLK}`;    BG_BLK=`tput setab ${_BLK}`;
  FG_RED=`tput setaf ${_RED}`;    BG_RED=`tput setab ${_RED}`;
  FG_GRN=`tput setaf ${_GRN}`;    BG_GRN=`tput setab ${_GRN}`;
  FG_YLW=`tput setaf ${_YLW}`;    BG_YLW=`tput setab ${_YLW}`;
  FG_BLU=`tput setaf ${_BLU}`;    BG_BLU=`tput setab ${_BLU}`;
  FG_PUR=`tput setaf ${_PUR}`;    BG_PUR=`tput setab ${_PUR}`;
  FG_CYN=`tput setaf ${_CYN}`;    BG_CYN=`tput setab ${_CYN}`;
  FG_WHT=`tput setaf ${_WHT}`;    BG_WHT=`tput setab ${_WHT}`;
  # Text Effects
  FX_BOLD_ON=`tput bold`;         FX_BOLD_OFF=`tput dim`;
  FX_UNDERLINE_ON=`tput smul`;    FX_UNDERLINE_OFF=`tput rmul`;
  FX_STANDOUT_ON=`tput smso`;     FX_STANDOUT_OFF=`tput rmso`;
  FX_REVERSE=`tput rev`
}
export register_colors_tput;
#
# ascii based colors
#
register_colors_ascii ()
{
  RESET='\033[0m'
  # Foreground ------------------ Background
  FG_BLK='\033[30m';    BG_BLK='\033[40m';
  FG_RED='\033[31m';    BG_RED='\033[41m';
  FG_GRN='\033[32m';    BG_GRN='\033[42m';
  FG_YLW='\033[33m';    BG_YLW='\033[43m';
  FG_BLU='\033[34m';    BG_BLU='\033[44m';
  FG_PUR='\033[35m';    BG_PUR='\033[45m';
  FG_CYN='\033[36m';    BG_CYN='\033[46m';
  FG_WHT='\033[37m';    BG_WHT='\033[47m';
  # Text Effectsf
  FX_BOLD_ON='\033[1m';         FX_BOLD_OFF='\033[0m';
  FX_UNDERLINE_ON='\033[4m';    FX_UNDERLINE_OFF='\033[0m';
  FX_STANDOUT_ON='\033[5m';     FX_STANDOUT_OFF='\033[0m';
  FX_REVERSE='\033[7m'
}
export -f register_colors_ascii;
# ASCII sequence helper
function generate_ascii_sequence ()
{
  local fg;     fg=${1-${_FG}};    shift
  local bg;     bg=${1-${_BG}};    shift
  local bold;   bold=${1-${_BB}};  shift
  __ASCII="\033[$([[ "${bold}" == "true" ]] && echo 1 || echo 0 );3${fg}m\033[4${bg}m"
}
export -f generate_ascii_sequence
#
# Foreground helper
#
function set_foreground ()
{
  local index;  index=$1;   shift
  _FG=${index}
}
export -f set_foreground
#
# Background helper
#
function set_background ()
{
  local index;  index=$1;   shift
  _BG=${index}
}
export -f set_background
# Toggle bold
function set_bold ()
{
  local state;  state=${1-${_BB}};  shift
  case "${state}" in
    "true"|"on"|true)
      _BB="true"
      ;;
    *)
      _BB="false"
      ;;
  esac
}
export -f set_bold
# Color refresh helper
function refresh_colors ()
{
  local tool;   tool=${1-${_DEFAULT_COLOR_TOOL}};   shift
  case ${tool} in
    tput)
      echo -ne `tput setaf ${_FG}`;
      echo -ne `tput setab ${_BG}`;
      [[ "${_BB}" == "true" ]] \
        && echo -ne `tput bold` \
        || echo -ne `tput dim`
      ;;
    *)
      generate_ascii_sequence
      printf '%b' "${__ASCII}"
      ;;
  esac
}
export -f refresh_colors
# Color reset helper
function reset_colors ()
{
  local tool;   tool=${1-${_DEFAULT_COLOR_TOOL}};   shift
  case ${tool} in
    tput)
      echo -ne `tput sgr0`
      ;;
    *)
      printf '%b' "\033[0m"
      ;;
  esac
}
export -f reset_colors
#
# ascii color table
#
color_table_ascii ()
{
  local sample;   sample=${1-' CLR'};  shift
  data=".TS\n"
  data+="tab(;) allbox;\n"
  data+="c c c c c c c c.\n"
  for ((f = 0; f < 8; f++)); do
    for ((b = 0; b < 8; b++)); do
      set_bold false
      set_foreground ${f}
      set_background ${b}
      refresh_colors
      data+=$( echo -ne "${sample}" )
      [ ${b} -lt 7 ] && data+=$( echo -ne ";" )
    done
    reset_colors
    data+="\n"
    for ((b = 0; b < 8; b++)); do
      set_bold true
      set_foreground ${f}
      set_background ${b}
      refresh_colors
      data+=$( echo -ne "${sample}" )
      [ ${b} -lt 7 ] && data+=$( echo -ne ";" )
    done
    reset_colors
    data+="\n"
  done
  data+=".TE"
  dump data
  echo "$( echo -ne "${data}" | groff -t -Tascii | sed '/^$/d' )"
}
export -f color_table_ascii
#action_ascii-colors()   { color_table_ascii; }
#usage_ascii-colors ()   { echo "ascii-colors"; }
clrev ()        {   echo -n "${FX_REVERSE}";   }
clbold ()       {   echo -n "${FX_BOLD_ON}";   }
clreset ()      {   echo -n "${RESET}";        }
clfred ()       {   echo -n "${FG_RED}";       }
clbred ()       {   echo -n "${BG_RED}";       }
clfblue ()      {   echo -n "${FG_BLU}";       }
clbblue ()      {   echo -n "${BG_BLU}";       }
clfgreen ()     {   echo -n "${FG_GRN}";       }
clbgreen ()     {   echo -n "${BG_GRN}";       }
clfblack ()     {   echo -n "${FG_BLK}";       }
clbblack ()     {   echo -n "${BG_BLK}";       }
clfwhite ()     {   echo -n "${FG_WHT}";       }
clbwhite ()     {   echo -n "${BG_WHT}";       }
clfcyan ()      {   echo -n "${FG_CYN}";       }
clbcyan ()      {   echo -n "${BG_CYN}";       }
clfyellow ()    {   echo -n "${FG_YLW}";       }
clbyellow ()    {   echo -n "${BG_YLW}";       }
clfmagenta ()   {   echo -n "${FG_PUR}";       }
clbmagenta ()   {   echo -n "${BG_PUR}";       }
#
# Default to load colors on include
#
register_colors