#!/usr/bin/env bash
#
# Tests for help.sh module
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/tests/harness.sh"

echo "=== help.sh ==="
echo

echo "[help_usage — display]"
assert_output "help_usage outputs USAGE_TITLE" "Test App" \
  bash -c "
    USAGE_TITLE='Test App'
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require help 2>/dev/null
    help_usage 2>&1 || true
  "

assert_output "help_usage outputs USE column header" "USE" \
  bash -c "
    USAGE_TITLE='Test App'
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require help 2>/dev/null
    help_usage 2>&1 || true
  "

assert_output "help_usage outputs DESCRIPTION column header" "DESCRIPTION" \
  bash -c "
    USAGE_TITLE='Test App'
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require help 2>/dev/null
    help_usage 2>&1 || true
  "

echo
echo "[usage_list — grouping]"
assert_output "usage_list groups routes by namespace" "verbosity:" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require help 2>/dev/null
    usage_list 2>&1
  "

assert_output "usage_list shows help namespace" "help:" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require help 2>/dev/null
    usage_list 2>&1
  "

echo
echo "[usage_namespace_list — filtering]"
assert_output "usage_namespace_list shows only help routes" "--help" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require help 2>/dev/null
    namespace='help'
    usage_namespace_list 'help' 2>&1
  "

assert_output "usage_namespace_list shows verbosity routes" "--debug" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require help 2>/dev/null
    namespace='verbosity'
    usage_namespace_list 'verbosity' 2>&1
  "

echo
echo "[help routes registered on require]"
assert_not_empty "help routes exist after require help" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require help 2>/dev/null
    route_match '--help'
  "

assert_not_empty "--list-commands route exists after require help" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require help 2>/dev/null
    route_match '--list-commands'
  "

test_summary
