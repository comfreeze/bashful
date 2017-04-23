#!/usr/bin/env bash

#
# CONFIG
###################
_DISPLAY_WIDTH=$( tput cols )
_DISPLAY_HEIGHT=$( tput lines )
__W=${_DISPLAY_WIDTH}
__H=${_DISPLAY_HEIGHT}

#
# MODULE LOGIC
###################
display_get_size () {
  dump_method $*
  _DISPLAY_WIDTH=$( tput cols )
  _DISPLAY_HEIGHT=$( tput lines )
  __W=${_DISPLAY_WIDTH}
  __H=${_DISPLAY_HEIGHT}
}
export -f display_get_size
display_width () {
  dump_method $*
  display_get_size
  echo "${__W}"; return ${__W}
}
export -f display_width
display_height () {
  dump_method $*
  display_get_size
  echo "${__H}"; return ${__H}
}
export -f display_height

#
# MODULE INIT
###################
display_get_size