#!/usr/bin/env bash

#
# CONFIG
###################
_CURSOR_UP="tput cuu "
_CURSOR_BACK="tput cub "
_CURSOR_FORWARD="tput cuf "
_CURSOR_MOVE="tput cup "
_CURSOR_MOVE_LAST="tput ll"
_CURSOR_SAVE="tput sc "
_CURSOR_RESTORE="tput rc "
_CURSOR_CLEAR="tput clear"
_CURSOR_CLEAR_LINE="tput el 1; tput el"
_CURSOR_CLEAR_CHARS="tput ech"
_CURSOR_CLEAR_SCREEN="tput ed"
_CURSOR_POS_X=0
_CURSOR_POS_Y=0

#
# MODULE LOGIC
###################
cursor_to () {
  dump_method
  local x;  x=${1-"0"};
  local y;  y=${2-"0"};
  ${_CURSOR_MOVE} ${y} ${x}
}
export -f cursor_to
cursor_up () {
  dump_method
  local s;  s=${1-"1"};
  ${_CURSOR_UP} ${s}
}
export -f cursor_up
cursor_down () {
  dump_method
  local s;  s=${1-"1"};
  cursor_get_pos
  local ty; ty=$((${_CURSOR_POS_Y} + ${s}))
  local tx; tx=${_CURSOR_POS_X}
  cursor_to ${tx} ${ty}
}
export -f cursor_down
cursor_left () {
  dump_method
  local s;  s=${1-"1"};
  ${_CURSOR_BACK} ${s}
}
export -f cursor_left
cursor_right () {
  dump_method
  local s;  s=${1-"1"};
  ${_CURSOR_FORWARD} ${s}
}
export -f cursor_right
cursor_end () {
  dump_method
  ${_CURSOR_MOVE_LAST}
}
export -f cursor_right
cursor_save () {
  dump_method
  ${_CURSOR_SAVE}
}
export -f cursor_save
cursor_restore () {
  dump_method
  ${_CURSOR_RESTORE}
}
export -f cursor_restore
cursor_clear () {
  dump_method
  case $1 in
    line|lines) cursor_clear_lines $2   ;;
    screen)     cursor_clear_screen     ;;
    chars)      cursor_clear_chars $2   ;;
    [0-9]*)     cursor_clear_chars $1   ;;
    *)          cursor_clear_full       ;;
  esac
}
export -f cursor_clear
cursor_clear_chars () {
  dump_method
  local c;  c=${1-"0"};   shift
  ${_CURSOR_CLEAR_CHARS} ${c}
}
export -f cursor_clear_chars
cursor_clear_lines () {
  dump_method
  local c;  c=${1-"0"};   shift
  local i=0;
  while (( "${i}" <= "${c}" )); do
    cursor_clear_line
    i=$((${i} + 1));
    (( ${i} <= "${c}" )) && cursor_down
  done
}
export -f cursor_clear_lines
cursor_clear_line () {
  dump_method
  ${_CURSOR_CLEAR_LINE}
}
export -f cursor_clear_line
cursor_clear_screen () {
  dump_method
  ${_CURSOR_CLEAR_SCREEN}
}
export -f cursor_clear_screen
cursor_clear_full () {
  dump_method
  ${_CURSOR_CLEAR}
}
export -f cursor_clear_full
cursor_get_pos () {
  dump_method
  exec < /dev/tty
  local oldTTY;  oldTTY=$(stty -g)
  stty raw -echo min 0
  # on my system, the following line can be replaced by the line below it
  echo -en "\033[6n" > /dev/tty
  # tput u7 > /dev/tty    # when TERM=xterm (and relatives)
  IFS=';' read -r -d R -a pos
  stty ${oldTTY}
  # change from one-based to zero based so they work with: tput cup $row $col
  _CURSOR_POS_Y=$((${pos[0]:2} - 1))    # strip off the esc-[
  _CURSOR_POS_X=$((${pos[1]} - 1))
}
export -f cursor_get_pos
cursor_x () {
  dump_method
  cursor_get_pos
  return ${_CURSOR_POS_X}
}
export -f cursor_x
cursor_y () {
  dump_method
  cursor_get_pos
  return ${_CURSOR_POS_Y}
}
export -f cursor_y
