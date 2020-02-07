#!/bin/bash

set -eE

DEBUG_TIME_IN_SEC=${DEBUG_TIME_IN_SEC:-300}

while test $# != 0
do
    case "$1" in
    -d) DEBUG=true ;;
    esac
    shift
done

handle_error() {
  if [[ "${DEBUG}" == "true" ]]; then
      sleep "${DEBUG_TIME_IN_SEC}"
  fi
  echo -n "${ERROR_LOG_FILE}" > "${RESULTS_DIR}/done"
}

trap 'handle_error' ERR

KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)
K8S_API_VERSION=$(curl -sSk \
-H "Authorization: Bearer $KUBE_TOKEN" \
"https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_PORT_443_TCP_PORT}/version" | jq -r '.major + "." +.minor')

RANCHER_K8S_VERSION="rke-${K8S_API_VERSION}"
echo "Rancher Kubernetes Version: ${RANCHER_K8S_VERSION}"

set -x

TAR_FILE_NAME="${TAR_FILE_NAME:-kb}"
CONFIG_DIR="${CONFIG_DIR:-/etc/kube-bench/cfg}"
RESULTS_DIR="${RESULTS_DIR:-/tmp/results}"
ERROR_LOG_FILE="${RESULTS_DIR}/error.log"
LOG_DIR="${RESULTS_DIR}/logs"

mkdir -p "${RESULTS_DIR}"

# etcd
if [[ "${OVERRIDE_BENCHMARK_VERSION}" != "" ]]; then
  echo "Using OVERRIDE_BENCHMARK_VERSION=${OVERRIDE_BENCHMARK_VERSION}"
  if [[ "$(pgrep etcd | wc -l)" -gt 0 ]]; then
    kube-bench run \
      --targets etcd \
      --scored \
      --nosummary \
      --noremediations \
      --v=5 \
      --config-dir="${CONFIG_DIR}" \
      --benchmark "${OVERRIDE_BENCHMARK_VERSION}" \
      --json \
      --log_dir "${LOG_DIR}" \
      --outputfile "${RESULTS_DIR}/etcd.json" 2> "${ERROR_LOG_FILE}"
  fi
else
  if [[ "$(pgrep etcd | wc -l)" -gt 0 ]]; then
    kube-bench run \
      --targets etcd \
      --scored \
      --nosummary \
      --noremediations \
      --v=5 \
      --config-dir "${CONFIG_DIR}" \
      --version "${RANCHER_K8S_VERSION}" \
      --json \
      --log_dir "${LOG_DIR}" \
      --outputfile "${RESULTS_DIR}/etcd.json" 2> "${ERROR_LOG_FILE}"
  fi
fi

# master (no etcd)
if [[ "${OVERRIDE_BENCHMARK_VERSION}" != "" ]]; then
  echo "Using OVERRIDE_BENCHMARK_VERSION=${OVERRIDE_BENCHMARK_VERSION}"
  if [[ "$(pgrep apiserver | wc -l)" -gt 0 ]]; then
    kube-bench run \
      --targets master \
      --scored \
      --nosummary \
      --noremediations \
      --v=5 \
      --config-dir="${CONFIG_DIR}" \
      --benchmark "${OVERRIDE_BENCHMARK_VERSION}" \
      --json \
      --log_dir "${LOG_DIR}" \
      --outputfile "${RESULTS_DIR}/master.json" 2> "${ERROR_LOG_FILE}"
  fi
else
  if [[ "$(pgrep apiserver | wc -l)" -gt 0 ]]; then
    kube-bench run \
      --targets master \
      --scored \
      --nosummary \
      --noremediations \
      --v=5 \
      --config-dir="${CONFIG_DIR}" \
      --version "${RANCHER_K8S_VERSION}" \
      --json \
      --log_dir "${LOG_DIR}" \
      --outputfile "${RESULTS_DIR}/master.json" 2> "${ERROR_LOG_FILE}"
  fi
fi

if [[ "${OVERRIDE_BENCHMARK_VERSION}" != "" ]]; then
  echo "Using OVERRIDE_BENCHMARK_VERSION=${OVERRIDE_BENCHMARK_VERSION}"
  if [[ "$(pgrep kubelet | wc -l)" -gt 0 ]]; then
    kube-bench run \
      --targets node \
      --scored \
      --nosummary \
      --noremediations \
      --v=5 \
      --config-dir="${CONFIG_DIR}" \
      --benchmark "${OVERRIDE_BENCHMARK_VERSION}" \
      --json \
      --log_dir "${LOG_DIR}" \
      --outputfile "${RESULTS_DIR}/node.json" 2> "${ERROR_LOG_FILE}"
  fi
else
  if [[ "$(pgrep kubelet | wc -l)" -gt 0 ]]; then
    kube-bench run \
      --targets node \
      --scored \
      --nosummary \
      --noremediations \
      --v=5 \
      --config-dir="${CONFIG_DIR}" \
      --version "${RANCHER_K8S_VERSION}" \
      --json \
      --log_dir "${LOG_DIR}" \
      --outputfile "${RESULTS_DIR}/node.json" 2> "${ERROR_LOG_FILE}"
  fi
fi

cd "${RESULTS_DIR}" || exit 1
tar -czf "${TAR_FILE_NAME}.tar.gz" *

if [[ "${DEBUG}" == "true" ]]; then
    sleep "${DEBUG_TIME_IN_SEC}"
fi

# Inform sonobuoy worker about completion of the job
echo -n "${RESULTS_DIR}/${TAR_FILE_NAME}.tar.gz" > "${RESULTS_DIR}/done"
