#!/bin/bash

set -eE

handle_error() {
  echo "false"
}

trap 'handle_error' ERR

REDHAT_COMMANDS="yum rpm dnf"
RHEL_PATH="/usr/lib/systemd/system"
OTHER_PATH="/usr/local/lib/systemd/system"

system_type() {
    for cmd in ${REDHAT_COMMANDS}; do
        if command -v "${cmd}" >/dev/null 2>&1; then
            echo "rhel"
            return
        fi
    done
    echo "other"
}

server_unit_file_ownership() {
    system_type=$1
    binary_name=$2
    if [ "${system_type}" = "rhel" ]; then
        res=$(stat -c %a "${RHEL_PATH}/${binary_name}-server.service")
        if [ "$res" != "644" ]; then
            echo "false"
            exit
        fi
        echo "true"
    else
        res=$(stat -c %a "${OTHER_PATH}/${binary_name}-server.service")
        if [ "${res}" != "644" ]; then
            echo "false"
            exit
        fi
        echo "true"
    fi
}

agent_unit_file_ownership() {
    system_type=$1
    binary_name=$2
    if [ "${system_type}" = "rhel" ]; then
        res=$(stat -c %a "${RHEL_PATH}/${binary_name}-agent.service")
        if [ "${res}" != "644" ]; then
            echo "false"
            exit
        fi
        echo "true"
    else
        res=$(stat -c %a "${OTHER_PATH}/${binary_name}-agent.service")
        if [ "${res}" != "644" ]; then
            echo "false"
            exit
        fi
        echo "true"
    fi
}

{
    case $1 in
        server)
            server_unit_file_ownership "$(system_type)" "rke2-server"
            ;;
        agent)
            agent_unit_file_ownership "$(system_type)" "rke2-agent"
            ;;
        *)
            echo "error: argument of either server or agent required"
            exit
            ;;
    esac
}
