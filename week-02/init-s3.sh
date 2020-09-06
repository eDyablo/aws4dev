#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${0}")"; pwd)"
bucket_api="${script_dir}/bucket.sh"

set -o errexit

text=$(cat <<TEXT
# Lohika Trainings

## AWS for developers course

### Week 2

Simple Storage Service (S3)
TEXT
)

echo "${text}" > "${script_dir}/readme.md"

${bucket_api} create ${@}
${bucket_api} upload ${@} "${script_dir}/readme.md"
