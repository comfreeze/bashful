#!/usr/bin/env bash

#
# Configuration source loader
#
load_config () {
  if [ -f "$1" ]; then
    verbose 1 "Loading environment configuration: ${1}"
    source "$1"
  fi
}
export -f load_config