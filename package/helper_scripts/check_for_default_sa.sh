#!/bin/bash

set -eE

handle_error() {
    echo "false"
}

trap 'handle_error' ERR

count_sa=$(kubectl get serviceaccounts --all-namespaces -o json | jq -r '.items[] | select(.metadata.name=="default") | select((.automountServiceAccountToken == null) or (.automountServiceAccountToken == true)) | select((.metadata.namespace!="default") and (.metadata.namespace!="kube-system"))' | jq .metadata.namespace | wc -l)
if [[ ${count_sa} -gt 0 ]]; then
    echo "false"
    exit
fi

count_rb=$(kubectl get rolebinding --all-namespaces -o json | jq -r '.items[].subjects[] | select(.kind=="ServiceAccount") | select(.name=="default")' | jq .metadata.namespace | wc -l)
if [[ ${count_rb} -gt 0 ]]; then
    echo "false"
    exit
fi

count_crb=$(kubectl get clusterrolebinding --all-namespaces -o json | jq -r '.items[].subjects[] | select(.kind=="ServiceAccount") | select(.name=="default")' | jq .metadata.namespace | wc -l)
if [[ ${count_crb} -gt 0 ]]; then
    echo "false"
    exit
fi

echo "true"

