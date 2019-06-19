#!/bin/bash

DEBUG_TIME_IN_SEC=${DEBUG_TIME_IN_SEC:-300}

while test $# != 0
do
    case "$1" in
    -d) DEBUG=true ;;
    esac
    shift
done

KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)
K8S_API_VERSION=$(curl -sSk \
-H "Authorization: Bearer $KUBE_TOKEN" \
https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/version | jq -r '.major + "." +.minor')

echo "Kubernetes version: ${K8S_API_VERSION}"

#set -e
set -x


TAR_FILE_NAME="${TAR_FILE_NAME:-kb}"
CONFIG_DIR="${CONFIG_DIR:-/cfg}"
RESULTS_DIR="${RESULTS_DIR:-/tmp/results}"

mkdir -p ${RESULTS_DIR}

# Run kube-bench on master
IS_MASTER=0
MASTER_GROUPS="1.1,1.2,1.3,1.4"

if [[ "$(pgrep apiserver)" -gt 0 ]]; then
  IS_MASTER=1
fi

if [[ "$(pgrep etcd)" -gt 0 ]]; then
  MASTER_GROUPS="${MASTER_GROUPS},1.5"
fi

# Skip 1.6, no scored
MASTER_GROUPS="${MASTER_GROUPS},1.7"

if [[ "${IS_MASTER}" -gt 0 ]]; then
  kube-bench master \
    --v=5 \
    --config-dir=${CONFIG_DIR} \
    --group=${MASTER_GROUPS} \
    --version ${K8S_API_VERSION} \
    --json \
  > "${RESULTS_DIR}/master.json"
  if [ $? -ne 0 ]; then
    echo "error running kube-bench master"
  fi
fi

# Run kube-bench on node
if [[ "$(pgrep kubelet)" -gt 0 ]]; then
  kube-bench node \
    --v=5 \
    --config-dir=${CONFIG_DIR} \
    --version ${K8S_API_VERSION} \
    --json \
  > "${RESULTS_DIR}/node.json"
  if [ $? -ne 0 ]; then
    echo "error running kube-bench node"
  fi
fi

cd ${RESULTS_DIR}
tar -czf ${TAR_FILE_NAME}.tar.gz *

if [[ "${DEBUG}" == "true" ]]; then
    sleep ${DEBUG_TIME_IN_SEC}
fi

# Inform sonobuoy worker about completion of the job
echo -n "${RESULTS_DIR}/${TAR_FILE_NAME}.tar.gz" > "${RESULTS_DIR}/done"
