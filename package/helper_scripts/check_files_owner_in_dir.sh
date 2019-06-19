#!/usr/bin/env bash

# This script is used to ensure the owner is set to root:root for
# the given directory and all the files in it
#
# inputs:
#   $1 = /full/path/to/directory
#
# outputs:
#   true/false

INPUT_DIR=$1

if [[ "${INPUT_DIR}" == "" ]]; then
    echo "false"
    exit
fi

if [[ $(stat -c %U:%G ${INPUT_DIR}) != "root:root" ]]; then
    echo "false"
    exit
fi

FILES_PERMISSIONS=$(stat -c %U:%G ${INPUT_DIR}/*)

while read -r fileInfo; do
  p=$(echo ${fileInfo} | cut -d' ' -f2)
  if [[ "$p" != "root:root" ]]; then
    echo "false"
    exit
  fi
done <<< "${FILES_PERMISSIONS}"


echo "true"
exit
