#!/usr/bin/env bash
#
# Test runner for bashful framework
# Discovers and runs all *_test.sh files in the root directory,
# then runs the integration smoke test.
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$( cd "${SCRIPT_DIR}/.." && pwd )"

TOTAL_PASS=0
TOTAL_FAIL=0
SUITES_PASS=0
SUITES_FAIL=0
FAILED_SUITES=()

run_suite ()
{
  local file; file="$1"
  local name; name="$( basename "${file}" )"
  echo
  echo "────────────────────────────────────────"
  echo " Running: ${name}"
  echo "────────────────────────────────────────"
  local output; output="$( bash "${file}" 2>&1 )"
  local rc=$?
  echo "${output}"

  # Extract pass/fail counts from summary line
  local pass; pass="$( echo "${output}" | grep -oP '\d+(?= passed)' | tail -1 )"
  local fail; fail="$( echo "${output}" | grep -oP '\d+(?= failed)' | tail -1 )"
  TOTAL_PASS=$(( TOTAL_PASS + ${pass:-0} ))
  TOTAL_FAIL=$(( TOTAL_FAIL + ${fail:-0} ))

  if [[ ${rc} -eq 0 ]]; then
    (( SUITES_PASS+=1 ))
  else
    (( SUITES_FAIL+=1 ))
    FAILED_SUITES+=( "${name}" )
  fi
}

# Discover per-module test files in root
for test_file in "${ROOT_DIR}"/*_test.sh; do
  [[ -f "${test_file}" ]] && run_suite "${test_file}"
done

# Run integration smoke test
if [[ -f "${SCRIPT_DIR}/smoke_test.sh" ]]; then
  run_suite "${SCRIPT_DIR}/smoke_test.sh"
fi

# Aggregate summary
echo
echo "════════════════════════════════════════"
echo " All Suites: $(( SUITES_PASS + SUITES_FAIL )) run, ${SUITES_PASS} passed, ${SUITES_FAIL} failed"
echo " All Tests:  $(( TOTAL_PASS + TOTAL_FAIL )) run, ${TOTAL_PASS} passed, ${TOTAL_FAIL} failed"
if [[ ${SUITES_FAIL} -gt 0 ]]; then
  echo " Failed:     ${FAILED_SUITES[*]}"
fi
echo "════════════════════════════════════════"

[[ ${SUITES_FAIL} -eq 0 ]] && exit 0 || exit 1
