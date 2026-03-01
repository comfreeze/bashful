#!/usr/bin/env bash
#
# Tests for router.sh module
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/tests/harness.sh"

echo "=== router.sh ==="
echo

echo "[route_load — single object]"
assert_output "route_load registers a single route" "my_action" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    route_load '{\"namespace\":\"test\",\"use\":\"--do-thing\",\"description\":\"A test\",\"callback\":\"my_action\"}'
    echo \"\${__ACTIVE_ROUTES}\"
  "

assert_output "route_load merges defaults from ROUTE_TEMPLATE" "\"visible\": \"true\"" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    route_load '{\"namespace\":\"test\",\"use\":\"--vis\",\"callback\":\"noop\"}'
    echo \"\${__ACTIVE_ROUTES}\" | jq '.routes[-1]'
  "

echo
echo "[route_load — array]"
assert_output "route_load handles JSON array of routes" "alpha" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    route_load '[{\"namespace\":\"test\",\"use\":\"--a\",\"callback\":\"alpha\"},{\"namespace\":\"test\",\"use\":\"--b\",\"callback\":\"beta\"}]'
    echo \"\${__ACTIVE_ROUTES}\"
  "

assert_output "route_load array registers both routes" "beta" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    route_load '[{\"namespace\":\"test\",\"use\":\"--a\",\"callback\":\"alpha\"},{\"namespace\":\"test\",\"use\":\"--b\",\"callback\":\"beta\"}]'
    echo \"\${__ACTIVE_ROUTES}\"
  "

echo
echo "[route_match — single pattern]"
assert_not_empty "route_match finds exact use match" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    route_load '{\"namespace\":\"test\",\"use\":\"--foo\",\"callback\":\"do_foo\"}'
    route_match '--foo'
  "

echo
echo "[route_match — multi-pattern with |]"
assert_not_empty "route_match finds first alternative in pipe-delimited use" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    route_load '{\"namespace\":\"test\",\"use\":\"-h|--help\",\"callback\":\"show_help\"}'
    route_match '-h'
  "

assert_not_empty "route_match finds second alternative in pipe-delimited use" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    route_load '{\"namespace\":\"test\",\"use\":\"-h|--help\",\"callback\":\"show_help\"}'
    route_match '--help'
  "

echo
echo "[route_match — pattern as use fallback]"
assert_not_empty "route_match falls back to use-split pattern matching" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    route_load '{\"namespace\":\"test\",\"use\":\"--start|--begin\",\"callback\":\"do_start\"}'
    route_match '--begin'
  "

echo
echo "[route_match — no match]"
assert_equals "route_match returns empty on no match" "" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    route_match '--nonexistent' 2>/dev/null
    echo -n ''
  "

echo
echo "[route — dispatch]"
assert_output "route dispatches callback for matched arg" "CALLED" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    my_cb() { echo 'CALLED'; }
    export -f my_cb
    route_load '{\"namespace\":\"test\",\"use\":\"--go\",\"callback\":\"my_cb\"}'
    route '--go' 2>/dev/null
  "

echo
echo "[Custom namespace routes]"
assert_output "routes in custom namespace are stored" "\"namespace\": \"custom\"" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    route_load '{\"namespace\":\"custom\",\"use\":\"--custom-cmd\",\"callback\":\"custom_fn\"}'
    echo \"\${__ACTIVE_ROUTES}\" | jq '.routes[-1]'
  "

test_summary
