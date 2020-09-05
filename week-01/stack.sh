#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${0}")"; pwd)"

function init() {
  while ((${#})); do
    case "${1}" in
      -key-name ) key_pair_name="${2}"; shift 2;;
      -key-name=* ) key_pair_name="${1#*=}"; shift 1;;
      -profile ) profile="${2}"; shift 2;;
      -profile=* ) profile="${1#*=}"; shift 1;;
      -stack-name ) stack_name="${2}"; shift 2;;
      -stack-name=* ) stack_name="${1#*=}"; shift 1;;
      * ) args+=("${1}"); shift 1;;
    esac
  done

  aws='aws'
  profile="${profile:-${AWS_DEFAULT_PROFILE}}"
  stack_name="${stack_name:-SausterStack}"
  command="${args[0]}"
}

function check_profile() {
  if [ ! ${profile} ]; then
    echo 'ERROR: No profile specified. Please use -profile option or set AWS_DEFAULT_PROFILE variable.'
    exit 1
  fi
}

function check_key_pair() {
  if [ ! ${key_pair_name} ]; then
    echo 'ERROR: No EC2 key pair name is set. Please use -key-name option.'
    exit 1
  fi
}

function create() {
  check_profile
  check_key_pair
  ${aws} \
    --profile="${profile}" \
    cloudformation create-stack \
    --stack-name "${stack_name}" \
    --template-body "file://${script_dir}/stack.yaml" \
    --parameters ParameterKey=KeyName,ParameterValue="${key_pair_name}"
}

function delete() {
  check_profile
  ${aws} \
    --profile="${profile}" \
    cloudformation delete-stack \
    --stack-name "${stack_name}"
}

function update() {
  check_profile
  check_key_pair
  ${aws} \
    --profile="${profile}" \
    cloudformation update-stack \
    --stack-name "${stack_name}" \
    --use-previous-template \
    --parameters ParameterKey=KeyName,ParameterValue="${key_pair_name}"
}

function handle_command() {
  if [ ! ${command} ]; then
    echo 'No command is specified. Please use one of the following.'
    echo '  create'
    echo '  delete'
    exit 1
  fi
  case "${command}" in
    create ) create;;
    delete ) delete;;
    update ) update;;
  esac
}

init ${@}
handle_command
