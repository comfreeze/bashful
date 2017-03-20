#!/usr/bin/env bash

#
# Test empty parameters
#
configure() {
  target=$1;  shift;
  values=$2;  shift;
  [[ "${_INTERACTIVE}" = false ]] && not_empty ${target} "${target} cannot be empty, set the environment value or consult the help menu"
  if [ -z "${target}" ]; then
      verbose 1 "Summary: $*"
      echo "Enter a value (${values}): "; read val
      verbose 2 "User input value: ${val}"
      eval "${target}=${val}"
      echo "Do you wish to save this to ${_ENVFILE}? [Y/n]:"; read choice
      case "${choice}" in
        y|yes)
          verbose 3 "Writing value of $1 to ${_ENVFILE}"
          save_local "${target}=${val}"
        ;;
      esac
  fi
}
export -f configure
save_local() {
  [[ ! -f "${_ENVFILE}" ]] && echo "#!/usr/bin/env bash" > "${_ENVFILE}"
  echo "Do you wish to save this to ${_ENVFILE}? [Y/n]:"; read choice
  case "${choice}" in
    y|yes)
      verbose 3 "Writing value of $1 to ${_ENVFILE}"
      echo "$1" >> "${_ENVFILE}"
    ;;
  esac
}
export -f save_local