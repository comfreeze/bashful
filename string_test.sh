#!/usr/bin/env bash
#
# Tests for string.sh module
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/tests/harness.sh"

echo "=== string.sh ==="
echo

echo "[in_string]"
assert_output "in_string finds substring match" "true" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require string 2>/dev/null
    in_string 'foo' 'foobar'
  "

assert_output "in_string returns false for no match" "false" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require string 2>/dev/null
    in_string 'xyz' 'foobar'
  "

echo
echo "[real_length]"
assert_not_empty "real_length returns a number for plain string" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require string 2>/dev/null
    real_length 'hello'
  "

assert_output "real_length of 'hello' includes 5" "5" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require string 2>/dev/null
    real_length 'hello'
  "

echo
echo "[repeat_char]"
assert_not_empty "repeat_char produces output" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require string 2>/dev/null
    repeat_char '=' 5
  "

assert_equals "repeat_char '=' 5 produces =====" "=====" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require string 2>/dev/null
    repeat_char '=' 5
  "

echo
echo "[repeat_string]"
assert_not_empty "repeat_string produces output" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require string 2>/dev/null
    repeat_string 'ab' 3
  "

echo
echo "[char_count]"
assert "char_count counts spaces in string" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require string 2>/dev/null
    char_count ' ' 'a b c'
    [[ \$? -eq 2 ]]
  "

assert "char_count returns 0 for no matches" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    require string 2>/dev/null
    char_count 'x' 'hello'
    [[ \$? -eq 0 ]]
  "

test_summary
