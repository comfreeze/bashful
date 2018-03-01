#!/usr/bin/env bash

#
# CONFIG
###################

#
# CUSTOM LIBRARIES
###################
require output

#
# MODULE LOGIC
###################
#
# Check if a value is empty, error with provided message
# if empty.
#
# e.g. not_empty _TARGET_VAR_ "You really should provide _TARGET_VAR_"
#
not_empty()
{
  if [ -z "$1" ]; then
    error $*;
  fi
}
export -f not_empty
