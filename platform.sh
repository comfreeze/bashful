#!/usr/bin/env bash

#
# CONFIG
###################

#
# MODULE LOGIC
###################
#
# Test if current environment identifies as a Apple/Mac
#
is_apple ()
{
  if [[ $( uname -a | grep "Darwin" ) ]]; then
   return 0;
  fi
  return 1;
}
#
# Test if current environment identifies as a CYGWIN
#
is_cygwin ()
{
  if [[ $( uname -a | grep "CYGWIN" ) ]]; then
   return 0;
  fi
  return 1;
}
#
# Test if current environment identifies as a MINGW
#
is_mingw ()
{
  if [[ $( uname -a | grep "MINGW" ) ]]; then
   return 0;
  fi
  return 1;
}
#
# Test if current environment identifies as a MINGW
#
is_linux ()
{
  case 1 in
    is_apple)  return 0 ;;
    is_cygwin) return 0 ;;
    is_mingw)  return 0 ;;
  esac
  return 1;
}
#
# Test if current environment identifies as 64-bit
#
is_64bit ()
{
  if [[ $( uname -m | grep "x86_64" ) ]]; then
   return 0;
  fi
  return 1;
}
#
# Test if current environment identifies as 64-bit
#
is_32bit ()
{
  if [[ $( uname -m | grep "x86_64" ) ]]; then
   return 1;
  fi
  return 0;
}