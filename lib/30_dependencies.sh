#!/usr/bin/env bash
__FILES=()
for FILE in *; do
  if [[ -f ${FILE} ]] && [[ ${FILE:(-4)} = ".yml" ]]; then
    LEN=${#FILE}-4
    FILENAME=${FILE:0:${LEN}}
    verbose 5 "Discovered local docker compose file: ${FILENAME}"
    __FILES=( "${__FILES[@]}" "${FILENAME}=${FILE}" )
  fi
done
#
# Process a list of files and append to array
#
get_files () {
  target=$1;  shift

  __FILES=()
  for FILE in *; do
    if [[ -f ${FILE} ]] && [[ ${FILE:(-4)} = ".yml" ]]; then
      LEN=${#FILE}-4
      FILENAME=${FILE:0:${LEN}}
      verbose 5 "Discovered local docker compose file: ${FILENAME}"
      __FILES=( "${__FILES[@]}" "${FILENAME}=${FILE}" )
    fi
  done
}
export -f get_files
#
# Perform a series of operations on a given set
# of dependency folders (__REPOS)
#
perform_on_deps () {
  action=$1;    shift
#  [[ "${_FAKE}" = true ]] && action="echo ${action}"
  for DEP in "${_USER_DEPS[@]}"; do
    echo
    verbose 0 ${DEP}:
    ${action} "../${DEP}" "$( select_repos "${DEP}" )" $*
  done
}
export -f perform_on_deps
#
# Perform an operation against a dependency
#
dep_operation () {
  verbose 3 "dep_operation $*"
  target_dir=$1; shift;   # Target directory of operation (from base)
  repo_name=$1;  shift;   # Repository name, as shown in URL
  op=$*;                  # Operation to perform
  [[ "${_FAKE}" != true ]] && cd $target_dir;
  verbose 1 $op
  $op
}
export -f dep_operation
#
# Pull or update target dependencies
#
pull_or_update () {
  verbose 3 "pull_or_update $*"
  dir=$1; shift; repo=$1; shift
  dir_not_exists "$dir" ${_CONFIG_GITCMD} clone ${_CONFIG_GIT_BASE}${repo}.git ${dir}
  dir_exists "$dir" gitcmd "$dir" "$repo" pull --ff-only
}
export -f pull_or_update
#
# Print status of target dependencies
#
status () {
  verbose 3 "status $*"
  dir=$1; shift; repo=$1; shift
  dir_exists "$dir" gitcmd "$dir" "$repo" status --short
}
export -f status
#
# Perform custom git command on target dependencies
#
gitcmd () {
  verbose 3 "gitcmd $*"
  dir=$1; shift; repo=$1; shift
  dir_not_exists "$dir" echo "does not exist locally"
  dep_operation "$dir" "$repo" ${_CONFIG_GITCMD} $*
}
export -f gitcmd

[[ "${_FAKE}" = true ]] && _CONFIG_GITCMD="echo ${_CONFIG_GITCMD}"
[[ ${#_USER_DEPS} = "0" ]] && _USER_DEPS=( "${___DEPS[@]}" )
