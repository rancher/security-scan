#!/bin/bash

set -eE

handle_error() {
  echo "false"
}

trap 'handle_error' ERR

COUNT=$(find /etc/cni/net.d -name "*calico*" | wc -l)
if [ ${COUNT} -eq 0 ]; then
  echo "false"
  exit
fi

echo "true"
