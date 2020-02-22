#!/usr/bin/env bash

# This script is used to check the encrption provider config is set to aesbc
#
# outputs:
#   true/false

# TODO: Figure out the file location from the kube-apiserver commandline args
ENCRYPTION_CONFIG_FILE="/node/etc/kubernetes/ssl/encryption.yaml"

if [[ ! -f "${ENCRYPTION_CONFIG_FILE}" ]]; then
  echo "false"
  exit
fi

for provider in "$@"
do
  if grep "$provider" "${ENCRYPTION_CONFIG_FILE}"; then
    echo "true"
    exit
  fi
done

echo "false"
exit
