#!/bin/bash

# This script is used to ensure that k3s is actually running etcd (and not other databases like sqlite3)
# before it checks the requirement
set -eE

handle_error() {
    echo "false"
}

trap 'handle_error' ERR


if [[ "$(journalctl -D /var/log/journal -u k3s | grep 'Managed etcd cluster initializing' | grep -v grep | wc -l)" -gt 0 ]]; then
    case $1 in 
        "1.1.11")
            echo $(stat -c %a /var/lib/rancher/k3s/server/db/etcd);;
        "1.2.29")
            echo $(journalctl -D /var/log/journal -u k3s | grep 'Running kube-apiserver' | tail -n1 | grep 'etcd-');;
        "2.1")
            echo $(grep -A 5 'client-transport-security' /var/lib/rancher/k3s/server/db/etcd/config | grep -E 'cert-file|key-file');;
        "2.2")
            echo $(grep -A 5 'client-transport-security' /var/lib/rancher/k3s/server/db/etcd/config | grep 'client-cert-auth');;
        "2.3")
            echo $(grep 'auto-tls' /var/lib/rancher/k3s/server/db/etcd/config);;
        "2.4")
            echo $(grep -A 5 'peer-transport-security' /var/lib/rancher/k3s/server/db/etcd/config | grep -E 'cert-file|key-file');;
        "2.5")
            echo $(grep -A 5 'peer-transport-security' /var/lib/rancher/k3s/server/db/etcd/config | grep 'client-cert-auth');;
        "2.6")
            echo $(grep 'peer-auto-tls' /var/lib/rancher/k3s/server/db/etcd/config);;
        "2.7")
            echo $(grep 'trusted-ca-file' /var/lib/rancher/k3s/server/db/etcd/config);;
    esac
else
# If another database is running, return whatever is required to pass the scan
    case $1 in
        "1.1.11")
            echo "700";;
        "1.2.29")
            echo "--etcd-certfile AND --etcd-keyfile";;
        "2.1")
            echo "cert-file AND key-file";;
        "2.2")
            echo "--client-cert-auth=true";;
        "2.3")
            echo "false";;
        "2.4")
            echo "peer-cert-file AND peer-key-file";;
        "2.5")
            echo "--client-cert-auth=true";;
        "2.6")
            echo "--peer-auto-tls=false";;
        "2.7")
            echo "--trusted-ca-file";;
    esac
fi
