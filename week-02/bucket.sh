#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${0}")"; pwd)"

set -o errexit

function init() {
  while ((${#})); do
    case "${1}" in
      -bucket-name ) bucket_name="${2}"; shift 2;;
      -bucket-name=* ) bucket_name="${1#*=}"; shift 1;;
      -profile ) profile="${2}"; shift 2;;
      -profile=* ) profile="${1#*=}"; shift 1;;
      *) args+=("${1}"); shift 1;;
    esac
  done

  aws='aws'
  bucket_name="${bucket_name:-com.lohika.aws4d2020.eyablonskyi.glade}"
  profile="${profile:-${AWS_DEFAULT_PROFILE}}"
}

function check_profile() {
  if [ ! ${profile} ]; then
    echo 'ERROR: No profile specified. Please use -profile option or set AWS_DEFAULT_PROFILE variable.'
    exit 1
  fi
}

function create_bucket() {
  check_profile
  ${aws} \
    --profile="${profile}" \
    s3api create-bucket \
    --bucket="${bucket_name}"
  ${aws} \
    --profile="${profile}" \
    s3api put-bucket-versioning \
    --bucket="${bucket_name}" \
    --versioning-configuration Status=Enabled
}

function delete_bucket() {
  check_profile
  ${aws} \
    --profile="${profile}" \
    s3api delete-bucket \
    --bucket="${bucket_name}"
}

function upload_file() {
  check_profile
  if [ ! "${1}" ]; then
    echo 'ERROR: No file specified.'
    exit 1
  fi
  ${aws} \
    --profile="${profile}" \
    s3api put-object \
    --bucket="${bucket_name}" \
    --key="$(basename "${1}")" \
    --body="${1}"
}

function handle_command() {
  if [ ! "${1}" ]; then
    echo 'No command is specified. Please use one of the following.'
    echo '  create'
    echo '  delete'
    echo '  upload'
    exit 1
  fi
  case "${1}" in
    create ) create_bucket;;
    delete ) delete_bucket;;
    upload ) upload_file "${2}";;
  esac
}

init ${@}
handle_command ${args[@]}
