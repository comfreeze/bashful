#!/usr/bin/env bash

#
# LIBRARIES
###################
require string
require lines
require colors

#
# CONFIG
###################
THEME_1ST=$(echo -e "${FG_GRN}")
THEME_2ND=$(echo -e "${FG_WHT}")
THEME_3RD=$(echo -e "${FG_BLU}")
THEME_4TH=$(echo -e "${FG_CYN}")
THEME_WRN=$(echo -e "${FG_YLW}")
THEME_ERR=$(echo -e "${FG_RED}")
THEME_SPACER=$(printf "%b" ${UR_DR})
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
    local TITLE;            TITLE=${1-"Untitled"};
    local POSITION;         POSITION=${2};
    local ALIGNMENT;        ALIGNMENT=${3};
    local WIDTH;            WIDTH=${4};
    local PAD_CHAR;         PAD_CHAR=${5-${LR_RR}};
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
### Title() {
function box_title() {
    local TITLE;         TITLE=${1-"Untitled"}
    printf "%b\u2002%s\u2002%b" ${LR_RT} ${TITLE} ${LT_RR}
}
export -f box_title
### Start
function box_start() {
    box_boundary $1 ${BOX_START} ${2-${ALIGN_LEFT}} ${3-${THEME_BOX_DEFAULT_WIDTH}}
    SPACER="${SPACER}${THEME_SPACER}"
}
export -f box_start
### End
function box_end() {
    local SPACER_LENGTH;        SPACER_LENGTH=$(real_length "${SPACER}")
    local THEME_SPACER_LENGTH;  THEME_SPACER_LENGTH=$(real_length "${THEME_SPACER}");
    local t;                    t=$(expr ${SPACER_LENGTH} - ${THEME_SPACER_LENGTH});
#    echo "${SPACER_LENGTH} - ${THEME_SPACE_LENGTH} - ${t}"
    SPACER="${SPACER:0:${t}}"
    box_boundary "$1" ${BOX_FINISH} ${2-${ALIGN_RIGHT}} ${3-${THEME_BOX_DEFAULT_WIDTH}}
}
export -f box_end
### Content
function box_line() {
    box_boundary "$1" ${BOX_LINE} ${2-${ALIGN_LEFT}} ${3-${THEME_BOX_DEFAULT_WIDTH}} "\u2002"
}
export -f box_line
function box_misc() {
    box_boundary "$1" ${BOX_MISC} ${2-${ALIGN_LEFT}} ${3-${THEME_BOX_DEFAULT_WIDTH}}
}
export -f box_misc
## Calculations
function real_length() {
    local LENGTH1; LENGTH1=$(echo "$1" | awk '{ print length }')
    local LENGTH2; LENGTH2=$(echo "${#1}")
    local LENGTH3; LENGTH3=$(expr length "${1}")
    # echo "$LENGTH1 - $LENGTH2 - $LENGTH3"
    if [ "$LENGTH1" -le "$LENGTH2" ] && [ "$LENGTH1" -le "$LENGTH3" ]; then
        echo "$LENGTH1";
    elif [ "$LENGTH2" -le "$LENGTH1" ] && [ "$LENGTH2" -le "$LENGTH3" ]; then
        echo "$LENGTH2";
    else
        echo "$LENGTH3";
    fi
}
export -f real_length