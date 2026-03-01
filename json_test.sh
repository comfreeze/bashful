#!/usr/bin/env bash
#
# Tests for json.sh module
#
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/tests/harness.sh"

echo "=== json.sh ==="
echo

echo "[json_merge_objects]"
assert_output "json_merge_objects merges two objects" "\"b\": \"2\"" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    json_merge_objects '{\"a\":\"1\"}' '{\"b\":\"2\"}'
  "

assert_output "json_merge_objects second object overrides first" "\"a\": \"override\"" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    json_merge_objects '{\"a\":\"1\"}' '{\"a\":\"override\"}'
  "

echo
echo "[json_get_key]"
assert_equals "json_get_key extracts value by key" "bar" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    json_get_key 'foo' '{\"foo\":\"bar\",\"baz\":\"qux\"}'
  "

assert_equals "json_get_key returns null for missing key" "null" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    json_get_key 'missing' '{\"foo\":\"bar\"}'
  "

echo
echo "[json_set_key]"
assert_output "json_set_key sets a key value" "\"name\": \"updated\"" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    myval='updated'
    myobj='{\"name\":\"original\"}'
    json_set_key 'name' myval myobj
  "

echo
echo "[json_append_object]"
assert_output "json_append_object adds to array" "\"added\"" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    base='{\"items\":[]}'
    item='{\"name\":\"added\"}'
    json_append_object 'items' base item
  "

echo
echo "[json_array_length]"
assert_equals "json_array_length counts array items" "3" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    arr='[1,2,3]'
    json_array_length arr
  "

assert_equals "json_array_length returns 0 for empty array" "0" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    arr='[]'
    json_array_length arr
  "

echo
echo "[json_get_array_item]"
assert_output "json_get_array_item gets item by index" "\"second\"" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    arr='[\"first\",\"second\",\"third\"]'
    json_get_array_item 1 arr
  "

echo
echo "[json_value_search]"
assert_output "json_value_search finds matching object" "my_callback" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    data='{\"items\":[{\"name\":\"alpha\",\"cb\":\"my_callback\"},{\"name\":\"beta\",\"cb\":\"other\"}]}'
    json_value_search 'items' 'name' 'alpha' data
  "

echo
echo "[json_group_objects]"
assert_not_empty "json_group_objects groups by key" \
  bash -c "
    source '${SCRIPT_DIR}/bashful.sh' 2>/dev/null
    data='{\"items\":[{\"type\":\"a\",\"val\":1},{\"type\":\"b\",\"val\":2},{\"type\":\"a\",\"val\":3}]}'
    json_group_objects data 'items' 'type'
  "

test_summary
