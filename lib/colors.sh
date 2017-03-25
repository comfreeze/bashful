#!/usr/bin/env bash

#
# CONFIG
###################

#
# MODULE LOGIC
###################
#
# Register color variables
#
register_colors () {
  case $1 in
    tput)   shift;  register_colors_tput "$*"   ;;
    *)              register_colors_tput "$*"   ;;
  esac
}
export -f register_colors
#
# tput based colors
#
register_colors_tput () {
  RESET=`tput sgr0`
  # Foreground ------------------ Background
  FG_BLACK=`tput setaf 0`;        BG_BLACK=`tput setab 0`;
  FG_RED=`tput setaf 1`;          BG_RED=`tput setab 1`;
  FG_GREEN=`tput setaf 2`;        BG_GREEN=`tput setab 2`;
  FG_YELLOW=`tput setaf 3`;       BG_YELLOW=`tput setab 3`;
  FG_BLUE=`tput setaf 4`;         BG_BLUE=`tput setab 4`;
  FG_MAGENTA=`tput setaf 5`;      BG_MAGENTA=`tput setab 5`;
  FG_CYAN=`tput setaf 6`;         BG_CYAN=`tput setab 6`;
  FG_WHITE=`tput setaf 7`;        BG_WHITE=`tput setab 7`;
  # Text Effects
  FX_BOLD_ON=`tput bold`;         FX_BOLD_OFF=`tput dim`;
  FX_UNDERLINE_ON=`tput smul`;    FX_UNDERLINE_OFF=`tput rmul`;
  FX_STANDOUT_ON=`tput smso`;     FX_STANDOUT_OFF=`tput rmso`;
  FX_REVERSE=`tput rev`
}
export register_colors_tput;
#
# Default to load colors on include
#
register_colors