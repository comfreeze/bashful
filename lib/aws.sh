#!/usr/bin/env bash

#
# AWS CLI preparation
#
assemble_aws() {
  set +e
  AWSCMD=$( command -v aws )
  if [ "${_CONFIG_AWSDOCKER}" = true ]; then
    AWSCMD="docker run -t impekable/awscli aws"
  else
    if [[ "${AWSCMD}" != "" ]]; then
      AWSCMD="${_CONFIG_SHELLCMD} -c ${AWSCMD}"
    fi
  fi
  dump 1 AWSCMD
}
export -f assemble_aws
#
# Authenticate with ECR
#
aws_login() {
  [[ "${_FAKE}" = true ]] && AWSCMD="echo ${AWSCMD}"
  if [[ "${AWSCMD}" = "" ]]; then
    if [[ "${_INTERACTIVE}" = true ]]; then
      echo "AWS CLI not found, use docker? [Y/n]"; read choice
      case "${choice}" in
        Y|y|yes)  _CONFIG_AWSDOCKER=true; assemble_aws;  ;;
        *)  error "Unable to locate valid AWS CLI."  ;;
      esac
    else
      error "Unable to locate valid AWS CLI."
    fi
  fi
  LOGIN=`${AWSCMD} --region ${_CONFIG_AWSREG} ecr get-login`
  eval "${LOGIN//$'\r'/}"
}
export -f aws_login
#
# Assemble the command
#
assemble_aws