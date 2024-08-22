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
IS_K3S=false
if pgrep k3s; then
  IS_K3S=true
fi

set +x # don't print the token
KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)
K8S_API_VERSION=$(curl -sSk \
  -H "Authorization: Bearer $KUBE_TOKEN" \
  "https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_PORT_443_TCP_PORT}/version" | jq -r '.major + "." +.minor')
if [ ${IS_RKE2} ] || [ ${IS_K3S} ] ; then
  K8S_API_VERSION=$(curl -sSk \
    -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_PORT_443_TCP_PORT}/version" | jq -r '.gitVersion')
fi
set -x

RANCHER_K8S_VERSION="${K8S_API_VERSION}"
echo "Rancher Kubernetes Version: ${RANCHER_K8S_VERSION}"

TAR_FILE_NAME="${TAR_FILE_NAME:-kb}"
CONFIG_DIR="${CONFIG_DIR:-/etc/kube-bench/cfg}"
# Handle read-only issue in custom benchmark mounts
if [[ "$CONFIG_DIR" != "/etc/kube-bench/cfg" ]]; then
  cp -r "$CONFIG_DIR" /tmp/cfg
  CONFIG_DIR=/tmp/cfg
fi
RESULTS_DIR="${RESULTS_DIR:-/tmp/results}"
ERROR_LOG_FILE="${RESULTS_DIR}/error.log"
LOG_DIR="${RESULTS_DIR}/logs"
JOURNAL_LOG="${JOURNAL_LOG:-/var/log/journal}"
if [[ "$(journalctl -D $JOURNAL_LOG --lines=0 2>&1 | grep -s 'No such file or directory' | wc -l)" -gt 0 ]]; then
  JOURNAL_LOG=/run/log/journal
  find $CONFIG_DIR -name '*.yaml' | xargs -n1 sed -i 's|/var/log/journal|/run/log/journal|g'
fi
mkdir -p "${RESULTS_DIR}"

# etcd
if [[ "${OVERRIDE_BENCHMARK_VERSION}" != "" ]]; then
  if [[ "$(ps -e | grep etcd | wc -l)" -gt 0  ]]  || [[ "$(journalctl -m -u k3s | grep -m1 "Managed etcd cluster initializing" | wc -l )" -gt 0 ]] || [[ "$(journalctl -m -u k3s | grep -m1 "Managed etcd cluster bootstrap already complete and initialized" | wc -l )" -gt 0 ]]; then
    echo "etcd: Using OVERRIDE_BENCHMARK_VERSION=${OVERRIDE_BENCHMARK_VERSION}"
    kube-bench run \
      --targets etcd \
      --scored \
      --nosummary \
      --noremediations \
      --v=0 \
      --config-dir="${CONFIG_DIR}" \
      --benchmark "${OVERRIDE_BENCHMARK_VERSION}" \
      --json \
      --log_dir "${LOG_DIR}" \
      --outputfile "${RESULTS_DIR}/etcd.json" 2> "${ERROR_LOG_FILE}"
  fi
else
  if [[ "$(ps -e | grep etcd | wc -l)" -gt 0 ]]; then
    echo "etcd: Using RANCHER_K8S_VERSION=${RANCHER_K8S_VERSION}"
    kube-bench run \
      --targets etcd \
      --scored \
      --nosummary \
      --noremediations \
      --v=0 \
      --config-dir "${CONFIG_DIR}" \
      --version "${RANCHER_K8S_VERSION}" \
      --json \
      --log_dir "${LOG_DIR}" \
      --outputfile "${RESULTS_DIR}/etcd.json" 2> "${ERROR_LOG_FILE}"
  fi
fi

# master (no etcd)
if [[ "${OVERRIDE_BENCHMARK_VERSION}" != "" ]]; then
  if [[ "$(pgrep kube-apiserver | wc -l)" -gt 0 ]]  || [[ "$(journalctl -D $JOURNAL_LOG -u k3s | grep -m1 'Running kube-apiserver' | wc -l)" -gt 0 ]]; then
    echo "master: Using OVERRIDE_BENCHMARK_VERSION=${OVERRIDE_BENCHMARK_VERSION}"
    kube-bench run \
      --targets master \
      --scored \
      --nosummary \
      --noremediations \
      --v=0 \
      --config-dir="${CONFIG_DIR}" \
      --benchmark "${OVERRIDE_BENCHMARK_VERSION}" \
      --json \
      --log_dir "${LOG_DIR}" \
      --outputfile "${RESULTS_DIR}/master.json" 2> "${ERROR_LOG_FILE}"
  fi
else
  if [[ "$(pgrep kube-apiserver | wc -l)" -gt 0 ]]; then
    echo "master: Using RANCHER_K8S_VERSION=${RANCHER_K8S_VERSION}"
    kube-bench run \
      --targets master \
      --scored \
      --nosummary \
      --noremediations \
      --v=0 \
      --config-dir="${CONFIG_DIR}" \
      --version "${RANCHER_K8S_VERSION}" \
      --json \
      --log_dir "${LOG_DIR}" \
      --outputfile "${RESULTS_DIR}/master.json" 2> "${ERROR_LOG_FILE}"
  fi
fi

kubeletconf="/node/var/lib/kubelet/config"

if [[ "${OVERRIDE_BENCHMARK_VERSION}" != "" ]]; then
  if [[ "$(pgrep kubelet | wc -l)" -gt 0 ]] || [[ "$(journalctl -D $JOURNAL_LOG -u k3s -u k3s-agent | grep -m1 'Running kubelet' | wc -l)" -gt 0 ]]; then
    echo "node: Using OVERRIDE_BENCHMARK_VERSION=${OVERRIDE_BENCHMARK_VERSION}"
    kube-bench run \
      --targets node \
      --scored \
      --nosummary \
      --noremediations \
      --v=0 \
      --config-dir="${CONFIG_DIR}" \
      --benchmark "${OVERRIDE_BENCHMARK_VERSION}" \
      --json \
      --log_dir "${LOG_DIR}" \
      --outputfile "${RESULTS_DIR}/node.json" 2> "${ERROR_LOG_FILE}"
  fi
else
  if [[ "$(pgrep kubelet | wc -l)" -gt 0 ]]; then
    echo "node: Using RANCHER_K8S_VERSION=${RANCHER_K8S_VERSION}"
    kube-bench run \
      --targets node \
      --scored \
      --nosummary \
      --noremediations \
      --v=0 \
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
  if [[ "$(pgrep kube-apiserver | wc -l)" -gt 0 ]] || [[ "$(journalctl -D $JOURNAL_LOG -u k3s | grep -m1 'Running kube-apiserver' | wc -l)" -gt 0 ]]; then
    for controlFile in $(find ${CONFIG_DIR}/${OVERRIDE_BENCHMARK_VERSION}/ -name '*.yaml' ! -name config.yaml ! -name master.yaml ! -name node.yaml ! -name etcd.yaml); do
        echo "controlFile: ${controlFile}"
        target=$(basename "${controlFile}" .yaml)
        kube-bench run \
          --targets "${target}" \
          --scored \
          --nosummary \
          --noremediations \
          --v=0 \
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
