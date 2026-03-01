#!/usr/bin/env bash
#
# Tests for verbosity.sh module (via bashful.sh entry point)
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/tests/harness.sh"

echo "=== verbosity.sh ==="
echo

echo "[set__vlevel_vs — flag parsing]"
assert_output "set__vlevel_vs parses -v to level 1" "ok" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    set__vlevel_vs '-v'
    [[ \"\${_V}\" -eq 1 ]] && echo 'ok' || echo 'fail'
  "

assert_output "set__vlevel_vs parses -vvv to level 3" "ok" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    set__vlevel_vs '-vvv'
    [[ \"\${_V}\" -eq 3 ]] && echo 'ok' || echo 'fail'
  "

assert_output "set__vlevel_vs parses -vvvvv to level 5" "ok" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    set__vlevel_vs '-vvvvv'
    [[ \"\${_V}\" -eq 5 ]] && echo 'ok' || echo 'fail'
  "

echo
echo "[set__vlevel_string — named levels]"
assert_output "set__vlevel_string maps 'error' to level 0" "ok" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    set__vlevel_string 'error'
    [[ \"\${_V}\" -eq 0 ]] && echo 'ok' || echo 'fail'
  "

assert_output "set__vlevel_string maps 'warn' to level 1" "ok" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    set__vlevel_string 'warn'
    [[ \"\${_V}\" -eq 1 ]] && echo 'ok' || echo 'fail'
  "

assert_output "set__vlevel_string maps 'info' to level 2" "ok" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    set__vlevel_string 'info'
    [[ \"\${_V}\" -eq 2 ]] && echo 'ok' || echo 'fail'
  "

assert_output "set__vlevel_string maps 'debug' to level 3" "ok" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    set__vlevel_string 'debug'
    [[ \"\${_V}\" -eq \"\${__DEBUG}\" ]] && echo 'ok' || echo 'fail'
  "

assert_output "set__vlevel_string maps 'trace' to level 4" "ok" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    set__vlevel_string 'trace'
    [[ \"\${_V}\" -eq 4 ]] && echo 'ok' || echo 'fail'
  "

echo
echo "[verbose — conditional output]"
assert_output "verbose outputs at matching level" "hello" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    set__vlevel 2
    verbose 2 'hello' 2>&1
  "

assert_equals "verbose suppresses output below level" "" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    set__vlevel 0
    verbose 2 'hidden' 2>&1
  "

echo
echo "[dump/dump_method — trace output]"
assert_not_empty "dump produces output at trace level" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    set__vlevel 4
    MY_VAR='test_value'
    dump MY_VAR 2>&1
  "

assert_not_empty "dump_method produces output at info level" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    set__vlevel 2
    test_fn() { dump_method \"\$@\"; }
    test_fn arg1 2>&1
  "

test_summary
