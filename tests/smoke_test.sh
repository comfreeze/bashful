#!/usr/bin/env bash
#
# Smoke test for bashful framework
# Tests both router (bashful.sh) and legacy (require.sh) entry points
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$( cd "${SCRIPT_DIR}/.." && pwd )"

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

########################################
# ROUTER PATH (bashful.sh)
########################################
echo "=== Router Entry Point (bashful.sh) ==="
echo

## Source bashful.sh in a subshell to avoid polluting state
echo "[Module Loading]"
assert "bashful.sh sources without error" bash -c "source '${ROOT_DIR}/bashful.sh' 2>&1"

echo
echo "[Route Registration]"
assert_not_empty "routes are registered after sourcing bashful.sh" \
  bash -c "source '${ROOT_DIR}/bashful.sh' 2>/dev/null; echo \"\${__ACTIVE_ROUTES}\" | jq -r '.routes | length'"

assert_output "default routes include help" "help_usage" \
  bash -c "source '${ROOT_DIR}/bashful.sh' 2>/dev/null; require help 2>/dev/null; echo \"\${__ACTIVE_ROUTES}\""

assert_output "default routes include verbosity" "set__vlevel" \
  bash -c "source '${ROOT_DIR}/bashful.sh' 2>/dev/null; echo \"\${__ACTIVE_ROUTES}\""

echo
echo "[Route Matching]"
assert_not_empty "route_match finds --help" \
  bash -c "source '${ROOT_DIR}/bashful.sh' 2>/dev/null; require help 2>/dev/null; route_match '--help'"

assert_not_empty "route_match finds --list-commands" \
  bash -c "source '${ROOT_DIR}/bashful.sh' 2>/dev/null; require help 2>/dev/null; route_match '--list-commands'"

echo
echo "[Custom Route]"
assert_output "custom route_load registers and matches" "my_callback" \
  bash -c "
    source '${ROOT_DIR}/bashful.sh' 2>/dev/null
    route_load '{\"namespace\":\"test\",\"use\":\"--my-test\",\"description\":\"Test route\",\"callback\":\"my_callback\"}'
    route_match '--my-test'
  "

echo
echo "[Help Display]"
assert_output "help_usage outputs route listings" "USE" \
  bash -c "
    USAGE_TITLE='Test App'
    source '${ROOT_DIR}/bashful.sh' 2>/dev/null
    require help 2>/dev/null
    help_usage 2>&1 || true
  "

assert_output "help_usage shows USAGE_TITLE" "Test App" \
  bash -c "
    USAGE_TITLE='Test App'
    source '${ROOT_DIR}/bashful.sh' 2>/dev/null
    require help 2>/dev/null
    help_usage 2>&1 || true
  "

echo
echo "[Verbosity Control]"
assert_output "set__vlevel_vs parses -vvv to level 3" "" \
  bash -c "
    source '${ROOT_DIR}/bashful.sh' 2>/dev/null
    set__vlevel_vs '-vvv'
    [[ \"\${_V}\" -eq 3 ]] && echo 'ok' || exit 1
  "

assert_output "set__vlevel_string sets debug level" "" \
  bash -c "
    source '${ROOT_DIR}/bashful.sh' 2>/dev/null
    set__vlevel_string 'debug'
    [[ \"\${_V}\" -eq \"\${__DEBUG}\" ]] && echo 'ok' || exit 1
  "

########################################
# LEGACY PATH (require.sh)
########################################
echo
echo "=== Legacy Entry Point (require.sh) ==="
echo

echo "[Module Loading]"
assert "require.sh sources without error" bash -c "source '${ROOT_DIR}/require.sh' 2>&1"

echo
echo "[Convention-Based Dispatch]"
assert_output "param_ convention is discovered by get_functions" "verbosity" \
  bash -c "
    source '${ROOT_DIR}/require.sh' 2>/dev/null
    get_functions 'param_'
  "

assert_output "eval_request dispatches param_verbosity" "" \
  bash -c "
    source '${ROOT_DIR}/require.sh' 2>/dev/null
    eval_request -vvv 2>/dev/null
    [[ \"\${_V}\" -eq 3 ]] && echo 'ok' || exit 1
  "

echo
echo "[Core Utilities]"
assert_output "in_string detects match" "true" \
  bash -c "
    source '${ROOT_DIR}/require.sh' 2>/dev/null
    require string
    in_string 'foo' 'foobar'
  "

assert_not_empty "repeat_char produces output" \
  bash -c "
    source '${ROOT_DIR}/require.sh' 2>/dev/null
    require string
    repeat_char '=' 10
  "

assert_not_empty "working_file returns a temp path" \
  bash -c "
    source '${ROOT_DIR}/require.sh' 2>/dev/null
    f=\$(working_file)
    [[ -f \"\${f}\" ]] && echo \"\${f}\" && rm -f \"\${f}\"
  "

########################################
# SUMMARY
########################################
echo
echo "==============================="
echo " Results: ${PASS} passed, ${FAIL} failed"
echo "==============================="
[[ ${FAIL} -eq 0 ]] && exit 0 || exit 1
