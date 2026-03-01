#!/usr/bin/env bash
#
# Tests for module loader — both entry points
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/tests/harness.sh"

echo "=== require (module loader) ==="
echo

echo "[bashful.sh entry point]"
assert "bashful.sh sources without error" \
  bash -c "source '${SCRIPT_DIR}/bashful.sh' 2>&1"

assert_output "bashful.sh sets _LIB_DIR" "${SCRIPT_DIR}" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    echo \"\${_LIB_DIR}\"
  "

assert_output "bashful.sh populates _PATHS array" "${SCRIPT_DIR}" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    echo \"\${_PATHS[@]}\"
  "

echo
echo "[require.sh entry point]"
assert "require.sh sources without error" \
  bash -c "source '${SCRIPT_DIR}/require.sh' 2>&1"

assert_output "require.sh sets _LIB_DIR" "${SCRIPT_DIR}" \
  bash -c "
    source '${SCRIPT_DIR}/require.sh' 2>/dev/null
    echo \"\${_LIB_DIR}\"
  "

echo
echo "[require loads module from _PATHS]"
assert "require loads string module" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require string 2>/dev/null
    type in_string >/dev/null 2>&1
  "

assert "require loads json module" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require json 2>/dev/null
    type json_get_key >/dev/null 2>&1
  "

echo
echo "[local override takes precedence]"
assert_output "local _PATHS entry overrides library module" "ok" \
  bash -c "
    TMPDIR=\$(mktemp -d)
    echo 'OVERRIDE_MARKER=yes' > \"\${TMPDIR}/testmod.sh\"
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    _PATHS=( \"\${TMPDIR}\" \"${SCRIPT_DIR}\" )
    require testmod 2>/dev/null
    [[ \"\${OVERRIDE_MARKER}\" == 'yes' ]] && echo 'ok' || echo 'fail'
    rm -rf \"\${TMPDIR}\"
  "

echo
echo "[legacy convention-based dispatch]"
assert_output "param_ convention discovered by get_functions" "verbosity" \
  bash -c "
    source '${SCRIPT_DIR}/require.sh' 2>/dev/null
    get_functions 'param_'
  "

assert_output "action_ convention discovered by get_functions" "fake" \
  bash -c "
    source '${SCRIPT_DIR}/require.sh' 2>/dev/null
    get_functions 'param_'
  "

assert "eval_request is defined after sourcing require.sh" \
  bash -c "
    source '${SCRIPT_DIR}/require.sh' 2>/dev/null
    type eval_request >/dev/null 2>&1
  "

test_summary
