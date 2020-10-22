#!/bin/bash

set -eEx

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

IS_RKE2=false
if pgrep rke2 &>/dev/null; then
  IS_RKE2=true
fi

KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)

K8S_API_VERSION=$(curl -sSk \
  -H "Authorization: Bearer $KUBE_TOKEN" \
  "https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_PORT_443_TCP_PORT}/version" | jq -r '.major + "." +.minor')
if [ ${IS_RKE2} ]; then
  K8S_API_VERSION=$(curl -sSk \
    -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_PORT_443_TCP_PORT}/version" | jq -r '.gitVersion')
fi

RANCHER_K8S_VERSION="${K8S_API_VERSION}"
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
  if [[ "$(pgrep -f /etcd | wc -l)" -gt 0 ]]; then
    echo "etcd: Using OVERRIDE_BENCHMARK_VERSION=${OVERRIDE_BENCHMARK_VERSION}"
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
  if [[ "$(pgrep -f /etcd | wc -l)" -gt 0 ]]; then
    echo "etcd: Using RANCHER_K8S_VERSION=${RANCHER_K8S_VERSION}"
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

KUBE_APISERVER_PROC="kube-apiserver"
if [ ! ${IS_RKE2} ]; then
  KUBE_APISERVER_PROC="/kube-apiserver"
fi

# master (no etcd)
if [[ "${OVERRIDE_BENCHMARK_VERSION}" != "" ]]; then
  if [[ "$(pgrep -f ${KUBE_APISERVER_PROC} | wc -l)" -gt 0 ]]; then
    echo "master: Using OVERRIDE_BENCHMARK_VERSION=${OVERRIDE_BENCHMARK_VERSION}"
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
  if [[ "$(pgrep -f ${KUBE_APISERVER_PROC} | wc -l)" -gt 0 ]]; then
    echo "master: Using RANCHER_K8S_VERSION=${RANCHER_K8S_VERSION}"
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

KUBELET_PROC="kubelet"
if [ ! ${IS_RKE2} ]; then
  KUBE_APISERVER_PROC="/kubelet"
fi

if [[ "${OVERRIDE_BENCHMARK_VERSION}" != "" ]]; then
  if [[ "$(pgrep -f ${KUBELET_PROC} | wc -l)" -gt 0 ]]; then
    echo "node: Using OVERRIDE_BENCHMARK_VERSION=${OVERRIDE_BENCHMARK_VERSION}"
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
  if [[ "$(pgrep -f ${KUBELET_PROC} | wc -l)" -gt 0 ]]; then
    echo "node: Using RANCHER_K8S_VERSION=${RANCHER_K8S_VERSION}"
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

# Run the scan for remaining controls
# TODO:
#   For now run on master nodes, refactor later to run as a
#   separate sonobuoy plugin of type=Job. But not sure if
#   there would be some controls which require running on
#   master nodes only
if [[ "${OVERRIDE_BENCHMARK_VERSION}" != "" ]]; then
  if [[ "$(pgrep -f ${KUBE_APISERVER_PROC} | wc -l)" -gt 0 ]]; then
    for controlFile in $(find ${CONFIG_DIR}/${OVERRIDE_BENCHMARK_VERSION} -name '*.yaml' ! -name config.yaml ! -name master.yaml ! -name node.yaml ! -name etcd.yaml); do
        echo "controlFile: ${controlFile}"
        target=$(basename "${controlFile}" .yaml)
        kube-bench run \
          --targets "${target}" \
          --scored \
          --nosummary \
          --noremediations \
          --v=5 \
          --config-dir="${CONFIG_DIR}" \
          --benchmark "${OVERRIDE_BENCHMARK_VERSION}" \
          --json \
          --log_dir "${LOG_DIR}" \
          --outputfile "${RESULTS_DIR}/${target}.json" 2> "${ERROR_LOG_FILE}"
    done
  fi
fi

cd "${RESULTS_DIR}" || exit 1
tar -czf "${TAR_FILE_NAME}.tar.gz" *

if [[ "${DEBUG}" == "true" ]]; then
    sleep "${DEBUG_TIME_IN_SEC}"
fi

# Inform sonobuoy worker about completion of the job
echo -n "${RESULTS_DIR}/${TAR_FILE_NAME}.tar.gz" > "${RESULTS_DIR}/done"
