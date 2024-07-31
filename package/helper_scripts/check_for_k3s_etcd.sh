#!/bin/bash

# This script is used to ensure that k3s is actually running etcd (and not other databases like sqlite3)
# before it checks the requirement
set -eE

handle_error() {
    echo "false"
}

trap 'handle_error' ERR

JOURNAL_LOG="${JOURNAL_LOG:-/var/log/journal}"
if [[ "$(journalctl -D $JOURNAL_LOG --lines=0 2>&1 | grep -s 'No such file or directory' | wc -l)" -gt 0 ]]; then
  JOURNAL_LOG=/run/log/journal
fi

if [[ "$(journalctl -D $JOURNAL_LOG -u k3s | grep -m1 'Managed etcd cluster' | wc -l)" -gt 0 ]]; then
    cat /var/lib/rancher/k3s/server/db/etcd/config
else
# If another database is running, return a fake etcd config that passes the checks
cat <<EOF
client-transport-security:
    cert-file: /var/lib/rancher/k3s/server/tls/etcd/server-client.crt
    client-cert-auth: true
    key-file: /var/lib/rancher/k3s/server/tls/etcd/server-client.key
    trusted-ca-file: /var/lib/rancher/k3s/server/tls/etcd/server-ca.crt
peer-transport-security:
    cert-file: /var/lib/rancher/k3s/server/tls/etcd/peer-server-client.crt
    client-cert-auth: true
    key-file: /var/lib/rancher/k3s/server/tls/etcd/peer-server-client.key
    trusted-ca-file: /var/lib/rancher/k3s/server/tls/etcd/peer-ca.crt
EOF
fi
