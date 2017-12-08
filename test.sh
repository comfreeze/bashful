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
#
# Filesystem helpers
#
dir_exists()
{
  verbose 4 "Directory existence check: $1"
  if [ -d "$1" ]; then
    verbose 3 "Directory exists: $1"
    shift;  $*
  fi
}
export -f dir_exists
dir_not_exists()
{
  verbose 4 "Directory existence check: $1"
  if [ ! -d "$1" ]; then
    verbose 3 "Directory does not exist: $1"
    shift;  $*
  fi
}
export -f dir_not_exists