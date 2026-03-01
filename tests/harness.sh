#!/usr/bin/env bash
#
# Shared test harness for bashful framework
# Source this from any *_test.sh file to get assert helpers and summary reporting.
#

PASS=0
FAIL=0

assert ()
{
  local label; label="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "  PASS: ${label}"
    (( PASS+=1 ))
  else
    echo "  FAIL: ${label}"
    (( FAIL+=1 ))
  fi
}

assert_equals ()
{
  local label;   label="$1";   shift
  local expect;  expect="$1";  shift
  local actual;  actual="$( "$@" 2>&1 )"
  if [[ "${actual}" == "${expect}" ]]; then
    echo "  PASS: ${label}"
    (( PASS+=1 ))
  else
    echo "  FAIL: ${label} (expected '${expect}', got '${actual}')"
    (( FAIL+=1 ))
  fi
}

assert_output ()
{
  local label;   label="$1";   shift
  local expect;  expect="$1";  shift
  local output;  output="$( "$@" 2>&1 )"
  if [[ "${output}" == *"${expect}"* ]]; then
    echo "  PASS: ${label}"
    (( PASS+=1 ))
  else
    echo "  FAIL: ${label} (expected '${expect}' in output)"
    (( FAIL+=1 ))
  fi
}

assert_not_empty ()
{
  local label;   label="$1";   shift
  local output;  output="$( "$@" 2>&1 )"
  if [[ -n "${output}" ]]; then
    echo "  PASS: ${label}"
    (( PASS+=1 ))
  else
    echo "  FAIL: ${label} (output was empty)"
    (( FAIL+=1 ))
  fi
}

test_summary ()
{
  echo
  echo "==============================="
  echo " Results: ${PASS} passed, ${FAIL} failed"
  echo "==============================="
  [[ ${FAIL} -eq 0 ]] && exit 0 || exit 1
}
