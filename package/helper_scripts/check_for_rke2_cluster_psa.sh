#!/bin/bash

set -eE

handle_error() {
    echo "false"
}

trap 'handle_error' ERR

pod_security_admission_file=$(ps aux | grep kube-apiserver |  grep -- --admission-control-config-file | sed 's%.*admission-control-config-file[= ]\([^ ]*\).*%\1%')
if [ -z ${pod_security_admission_file} ]; then
    echo "false"
    exit
fi

PSA_ENFORCE_MODE=${1}

if test -f "${pod_security_admission_file}"; then
    enforce_mode=$(grep "enforce:" ${pod_security_admission_file} | grep -o ${PSA_ENFORCE_MODE})
    if [ -z ${enforce_mode} ]; then
        echo "false"
        exit
    fi
    echo "true"
    exit
fi

echo "false"