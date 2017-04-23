#!/usr/bin/env bash

#
# CONFIG
###################


#
# MODULE LOGIC
###################
#
# Constant Reference for Line Drawing (Unicode)
#
# Key Index:
# Positions:
# - L(eft)
# - R(ight)
# - U(p)
# - D(own)
# Styles:
# - R(egular)
# - T(hick)
# - D(ouble)
# Dashes:
# - 2(-dashes)
# - 3(-dashes)
# - 4(-dashes)
# Extras:
# - C(ut corners)
#
# (POSITION)[DASHES](STYLE)
# example: (Left)(Thick) == LT
# example: (Up)(Regular) == UR
# example: (Up)(3 dashes)(Regular) == U3R
# example: (Up)(Cut corner)(Regular) == UCR
#
## Singles
export LR='\u2574';             export UR='\u2575';             export RR='\u2576';             export DR='\u2577';
export LT='\u2578';             export UT='\u2579';             export RT='\u257A';             export DT='\u257B';
## Cut Corners
export RR_DCR='\u256D';         export LR_DCR='\u256E';         export LR_UCR='\u256F';         export RR_UCR='\u2570';
## Mixed
export LR_RT='\u257C';          export UR_DT='\u257D';          export LT_RR='\u257E';          export UT_DR='\u257F';
## Solid Lines
export LR_RR='\u2500';          export LT_RT='\u2501';          export UR_DR='\u2502';          export UT_DT='\u2503';
## 2-dashed Lines
export L2R_R2R='\u254C';        export L2T_R2T='\u254D';        export U2R_D2R='\u254E';        export U2T_D2T='\u254F';
## 3-dashed Lines
export L3R_R3R='\u2504';        export L3T_R3T='\u2505';        export U3R_D3R='\u2506';        export U3T_D3T='\u2507';
## 4-dashed Lines
export L4R_R4R='\u2508';        export L4T_R4T='\u2509';        export U4R_D4R='\u250A';        export U4T_D4T='\u250B';
## Right-Lower
export RR_DR='\u250C';          export RT_DR='\u250D';          export RR_DT='\u250E';          export RT_DT='\u250F';
## Left-Lower
export LR_DR='\u2510';          export LT_DR='\u2511';          export LR_DT='\u2512';          export LT_DT='\u2513';
## Right-Upper
export RR_UR='\u2514';          export RT_UR='\u2515';          export RR_UT='\u2516';          export RT_UT='\u2517';
## Left-Upper
export LR_UR='\u2518';          export LT_UR='\u2519';          export LR_UT='\u251A';          export LT_UT='\u251B';
## Solid Attached
### Left
export LR_UR_DR='\u2524';       export LT_UR_DR='\u2525';       export LR_UT_DR='\u2526';       export LR_UR_DT='\u2527';
export LR_UT_DT='\u2528';       export LT_UT_DR='\u2529';       export LT_UR_DT='\u252A';       export LT_UT_DT='\u252B';
### Right
export RR_UR_DR='\u251C';       export RT_UR_DR='\u251D';       export RR_UT_DR='\u251E';       export RR_UR_DT='\u251F';
export RR_UT_DT='\u2520';       export RT_UT_DR='\u2521';       export RT_UR_DT='\u2522';       export RT_UT_DT='\u2523';
### Top
export LR_RR_UR='\u2534';       export LT_RR_UR='\u2535';       export LR_RT_UR='\u2536';       export LT_RT_UR='\u2537';
export LR_RR_UT='\u2538';       export LT_RR_UT='\u2539';       export LR_RT_UT='\u253A';       export LT_RT_UT='\u253B';
### Bottom
export LR_RR_DR='\u252C';       export LT_RR_DR='\u252D';       export LR_RT_DR='\u252E';       export LT_RT_DR='\u252F';
export LR_RR_DT='\u2530';       export LT_RR_DT='\u2531';       export LR_RT_DT='\u2532';       export LT_RT_DT='\u2533';
## Quads
export LR_RR_UR_DR='\u253C';    export LT_RR_UR_DR='\u253D';    export LR_RT_UR_DR='\u253E';    export LT_RT_UR_DR='\u253F';
export LR_RR_UT_DR='\u2540';    export LR_RR_UR_DT='\u2541';    export LR_RT_UT_DT='\u2542';    export LT_RR_UT_DR='\u2543';
export LR_RT_UT_DR='\u2544';    export LT_RR_UR_DT='\u2545';    export LR_RT_UR_DT='\u2546';    export LT_RT_UT_DR='\u2547';
export LT_RT_UR_DT='\u2548';    export LT_RR_UT_DT='\u2549';    export LR_RT_UT_DT='\u254A';    export LT_RT_UT_DR='\u254B';
## Double Lines
export LD_RD='\u2550';          export UD_DD='\u2551';          export RD_DR='\u2552';          export RR_DD='\u2553';
export RD_DD='\u2554';          export LD_DR='\u2555';          export LR_DD='\u2556';          export LD_DD='\u2557';
export RD_UR='\u2558';          export RR_UD='\u2559';          export RD_UD='\u255A';          export LD_UR='\u255B';
export LR_UD='\u255C';          export LD_UD='\u255D';
## Double Attached
export LD_UR_DR='\u255E';       export LR_UD_DD='\u255F';       export LD_UD_DD='\u2560';       export RD_UR_DR='\u2561';
export RR_UD_DD='\u2562';       export RD_UD_DD='\u2563';       export LD_RD_DR='\u2564';       export LR_RR_DD='\u2565';
export LD_RD_DD='\u2566';       export LD_RD_UR='\u2567';       export LR_RR_UD='\u2568';       export LD_RD_UD='\u2569';
## Double Quads
export LD_RD_UR_DR='\u256A';
export LR_RR_UD_DD='\u256B';
export LD_RD_UD_DD='\u256C';
## Slashes
export SLASH_UP='\u2571';
export SLASH_DOWN='\u2572';
export SLASH_CROSS='\u2673';
## Alignment
export ALIGN_CENTER='center';
export ALIGN_RIGHT='right';
export ALIGN_LEFT='left';
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