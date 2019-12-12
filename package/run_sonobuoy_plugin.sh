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
"https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_PORT_443_TCP_PORT}/version" | jq -r '.major + "." +.minor')

RANCHER_K8S_VERSION="rke-${K8S_API_VERSION}"
echo "Rancher Kubernetes Version: ${RANCHER_K8S_VERSION}"

#set -e
set -x

TAR_FILE_NAME="${TAR_FILE_NAME:-kb}"
CONFIG_DIR="${CONFIG_DIR:-/cfg}"
ETCD_CONFIG_DIR="${ETCD_CONFIG_DIR:-/etcdcfg}"
RESULTS_DIR="${RESULTS_DIR:-/tmp/results}"

mkdir -p "${RESULTS_DIR}"

# etcd
if [[ "${OVERRIDE_BENCHMARK_VERSION}" != "" ]]; then
  echo "Using OVERRIDE_BENCHMARK_VERSION=${OVERRIDE_BENCHMARK_VERSION}"
  if [[ "$(pgrep etcd)" -gt 0 ]]; then
    if ! kube-bench master \
      -f etcd.yaml \
      --scored \
      --nosummary \
      --noremediations \
      --v=5 \
      --config-dir="${ETCD_CONFIG_DIR}" \
      --benchmark "${OVERRIDE_BENCHMARK_VERSION}" \
      --json \
      --outputfile "${RESULTS_DIR}/etcd.json"
    then
      echo "error running kube-bench: etcd"
    fi
  fi
else
  if [[ "$(pgrep etcd)" -gt 0 ]]; then
    if ! kube-bench master \
      -f etcd.yaml \
      --scored \
      --nosummary \
      --noremediations \
      --v=5 \
      --config-dir="${ETCD_CONFIG_DIR}" \
      --version "${RANCHER_K8S_VERSION}" \
      --json \
      --outputfile "${RESULTS_DIR}/etcd.json"
    then
      echo "error running kube-bench: etcd"
    fi
  fi
fi

# master (no etcd)
if [[ "${OVERRIDE_BENCHMARK_VERSION}" != "" ]]; then
  echo "Using OVERRIDE_BENCHMARK_VERSION=${OVERRIDE_BENCHMARK_VERSION}"
  if [[ "$(pgrep apiserver)" -gt 0 ]]; then
    if ! kube-bench master \
      -f master.yaml \
      --scored \
      --nosummary \
      --noremediations \
      --v=5 \
      --config-dir="${CONFIG_DIR}" \
      --benchmark "${OVERRIDE_BENCHMARK_VERSION}" \
      --json \
      --outputfile "${RESULTS_DIR}/master.json"
    then
      echo "error running kube-bench: master"
    fi
  fi
else
  if [[ "$(pgrep apiserver)" -gt 0 ]]; then
    if ! kube-bench master \
      -f master.yaml \
      --scored \
      --nosummary \
      --noremediations \
      --v=5 \
      --config-dir="${CONFIG_DIR}" \
      --version "${RANCHER_K8S_VERSION}" \
      --json \
      --outputfile "${RESULTS_DIR}/master.json"
    then
      echo "error running kube-bench: master"
    fi
  fi
fi

if [[ "${OVERRIDE_BENCHMARK_VERSION}" != "" ]]; then
  echo "Using OVERRIDE_BENCHMARK_VERSION=${OVERRIDE_BENCHMARK_VERSION}"
  if [[ "$(pgrep kubelet)" -gt 0 ]]; then
    if ! kube-bench node \
      -f node.yaml \
      --scored \
      --nosummary \
      --noremediations \
      --v=5 \
      --config-dir="${CONFIG_DIR}" \
      --benchmark "${OVERRIDE_BENCHMARK_VERSION}" \
      --json \
      --outputfile "${RESULTS_DIR}/node.json"
    then
      echo "error running kube-bench: node"
    fi
  fi
else
  if [[ "$(pgrep kubelet)" -gt 0 ]]; then
    if ! kube-bench node \
      -f node.yaml \
      --scored \
      --nosummary \
      --noremediations \
      --v=5 \
      --config-dir="${CONFIG_DIR}" \
      --version "${RANCHER_K8S_VERSION}" \
      --json \
      --outputfile "${RESULTS_DIR}/node.json"
    then
      echo "error running kube-bench: node"
    fi
  fi
fi

cd "${RESULTS_DIR}" || exit 1
tar -czf "${TAR_FILE_NAME}.tar.gz" *

if [[ "${DEBUG}" == "true" ]]; then
    sleep "${DEBUG_TIME_IN_SEC}"
fi

# Inform sonobuoy worker about completion of the job
echo -n "${RESULTS_DIR}/${TAR_FILE_NAME}.tar.gz" > "${RESULTS_DIR}/done"
