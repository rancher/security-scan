#!/bin/bash

set -eE

handle_error() {
    echo "false"
}

trap 'handle_error' ERR

for namespace in kube-system kube-public default; do
  policy_count=$(/var/lib/rancher/rke2/bin/kubectl get networkpolicy -n ${namespace} -o json | jq -r '.items | length')
  if [ ${policy_count} -eq 0 ]; then
    echo "false"
    exit
  fi
done

echo "true"
