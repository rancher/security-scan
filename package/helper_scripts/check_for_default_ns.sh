#!/bin/bash

set -eE

handle_error() {
    echo "false"
}

trap 'handle_error' ERR

count=$(kubectl get all -n default -o json | jq .items[] | jq -r 'select((.metadata.name!="kubernetes"))' | jq .metadata.name | wc -l)
if [[ ${count} -gt 0 ]]; then
    echo "false"
    exit
fi

echo "true"

