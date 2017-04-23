#!/usr/bin/env bash

#
# LIBRARIES
###################
require display
require string
require lines
require colors
require string

#
# CONFIG
###################
SPACE=' '
SPACER=''
THEME_1ST=$(echo -e "${FG_GRN}")
THEME_2ND=$(echo -e "${FG_WHT}")
THEME_3RD=$(echo -e "${FG_BLU}")
THEME_4TH=$(echo -e "${FG_CYN}")
THEME_WRN=$(echo -e "${FG_YLW}")
THEME_ERR=$(echo -e "${FG_RED}")
THEME_SPACER=$(printf "%b" ${UR_DR})
THEME_BOX_DEFAULT_WIDTH=$( display_width )
## Box Types
BOX_START='top';
BOX_LINE='line';
BOX_MISC='misc';
BOX_FINISH='bottom';

#
# MODULE LOGIC
###################
## Box Helpers
### Boundary
function box_boundary() {
  dump_method $*
    local TITLE;            TITLE="${1-"Untitled"}";
    local POSITION;         POSITION="${2}";
    local ALIGNMENT;        ALIGNMENT="${3}";
    local WIDTH;            WIDTH="${4}";
    local PAD_CHAR;         PAD_CHAR="${5-${LR_RR}}";
    local TITLE_LENGTH;     TITLE_LENGTH=$(real_length "${TITLE}");
    local SPACER_LENGTH;    SPACER_LENGTH=$(real_length "${SPACER}")
    local FULL_LENGTH;      FULL_LENGTH=$(expr ${TITLE_LENGTH} + ${SPACER_LENGTH} + ${SPACER_LENGTH} + 2);
    local FILL;
    local LPAD;             local RPAD;
    local LEDGE;            local REDGE;
    case ${POSITION} in
        #                   Left Edge               Right Edge
        "${BOX_START}")     LEDGE=${6-${RR_DCR}};   REDGE=${7-${LR_DCR}};     ;;
        "${BOX_FINISH}")    LEDGE=${6-${RR_UCR}};   REDGE=${7-${LR_UCR}};     ;;
        "${BOX_LINE}")      LEDGE=${6-"\u2002"};    REDGE=${7-"\u2002"};      ;;
        **)                 LEDGE=${6-${RR_UR_DR}}; REDGE=${7-${LR_UR_DR}};   ;;
    esac
    case ${ALIGNMENT} in
        "${ALIGN_LEFT}")
            FILL=$(expr ${WIDTH} - ${FULL_LENGTH});
            LPAD=$(repeat_char "${PAD_CHAR}" 4);
            RPAD=$(repeat_char "${PAD_CHAR}" $(expr ${FILL} - 4));
        ;;
        "${ALIGN_RIGHT}")
            FILL=$(expr ${WIDTH} - ${FULL_LENGTH});
            LPAD=$(repeat_char "${PAD_CHAR}" $(expr ${FILL} - 4));
            RPAD=$(repeat_char "${PAD_CHAR}" 4);
        ;;
        "${ALIGN_CENTER}")
            FILL=$(expr ${WIDTH} - ${FULL_LENGTH});
            FILL=$(expr ${FILL} / 2);
            LPAD=$(repeat_char "${PAD_CHAR}" ${FILL});
            RPAD=$(repeat_char "${PAD_CHAR}" ${FILL});
            [[ ! $((TITLE_LENGTH % 2)) -eq 0 ]] && LPAD="${LPAD:1}"
        ;;
    esac
    printf "%s" "${SPACER}"
    printf "%b" "${LEDGE}"
    printf "%s" "${LPAD}${TITLE}${RPAD}";
    printf "%b" "${REDGE}"
    printf "%s" "${SPACER}"
#    printf "%s%b%s%s%s%b%s\n" "${SPACER}" ${LCORNER} ${LPAD} "${TITLE}" ${RPAD} ${RCORNER} "${SPACER}"
    echo
}
export -f box_boundary
function box_spacer_add () {
  dump_method $*
  local s;  s=${1-"${THEME_SPACER}"}; shift
  SPACER="${SPACER}${s}"
}
export -f box_spacer_add
function box_spacer_remove () {
  dump_method $*
  local s;  s=${1-"${THEME_SPACER}"}; shift
  local SPACER_LENGTH;        SPACER_LENGTH=$(real_length "${SPACER}")
  local THEME_SPACER_LENGTH;  THEME_SPACER_LENGTH=$(real_length "${s}");
  local t;  t=$(expr ${SPACER_LENGTH} - ${s});
  SPACER="${SPACER:0:${t}}"
}
export -f box_spacer_remove
### Title() {
function box_title() {
  dump_method $*
    local TITLE;         TITLE=${1-"Untitled"}
    printf "%b\u2002%s\u2002%b" ${LR_RT} ${TITLE} ${LT_RR}
}
export -f box_title
### Start
function box_start() {
  dump_method $*
  local title;  title=${1-"${SPACE}"};                      shift
  local align;  align=${1-"${ALIGN_LEFT}"};                 shift
  local width;  width=${1-"${THEME_BOX_DEFAULT_WIDTH}"};    shift
  box_boundary "${title}" "${BOX_START}" "${align}" "${width}"
  box_spacer_add
}
export -f box_start
### End
function box_end() {
  dump_method $*
  local title;  title=${1-"${SPACE}"};                      shift
  local align;  align=${1-"${ALIGN_LEFT}"};                 shift
  local width;  width=${1-"${THEME_BOX_DEFAULT_WIDTH}"};    shift
  box_spacer_remove
  box_boundary "${title}" "${BOX_FINISH}" "${align}" "${width}"
}
export -f box_end
### Content
function box_line() {
  dump_method $*
  local title;  title=${1-"${SPACE}"};                      shift
  local align;  align=${1-"${ALIGN_LEFT}"};                 shift
  local width;  width=${1-"${THEME_BOX_DEFAULT_WIDTH}"};    shift
  box_boundary "${title}" "${BOX_LINE}" "${align}" "${width}" "\u2002"
}
export -f box_line
function box_misc() {
  dump_method $*
  local title;  title=${1-"${SPACE}"};                      shift
  local align;  align=${1-"${ALIGN_LEFT}"};                 shift
  local width;  width=${1-"${THEME_BOX_DEFAULT_WIDTH}"};    shift
  box_boundary "${title}" "${BOX_MISC}" "${align}" "${width}"
}
export -f box_misc
## Calculations