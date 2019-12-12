#!/bin/bash

set -x
set -eE

defaultCMName=cis-$(date +"%Y-%m-%d-%H-%M-%S-%N")
OUTPUT_CONFIGMAPNAME=${OUTPUT_CONFIGMAPNAME:-${defaultCMName}}

SONOBUOY_NS=${SONOBUOY_NS:-sonobuoy}
SONOBUOY_POD_NAME=${SONOBUOY_POD_NAME:-sonobuoy}

DONE_ANNOTATION_KEY="field.cattle.io/sonobuoyDone"
DONE_ANNOTATION_VALUE="true"
ERROR_ANNOTATION_VALUE="error"

KBS_CONFIG_FILE_LOCATION=/etc/kbs/config.json

handle_error() {
  # Annotate self (pod) to signal "error"
  if ! kubectl -n "${SONOBUOY_NS}" \
    annotate pod "${SONOBUOY_POD_NAME}" \
    ${DONE_ANNOTATION_KEY}=${ERROR_ANNOTATION_VALUE}
  then
    echo "error annotating self pod"
  fi
  sleep infinity
}

trap 'handle_error' ERR

echo "Rancher: Running CIS Benchmarks"

# Run sonobuoy first
if ! sonobuoy master -v 3
then
  echo "error running sonobuoy"
  exit 1
fi

# Run summarizer
SONOBUOY_OUTPUT_DIR=${SONOBUOY_OUTPUT_DIR:-/tmp/sonobuoy}
SONOBUOY_OUTPUT_FILE=$(ls -1 "${SONOBUOY_OUTPUT_DIR}"/*.tar.gz)

KB_SUMMARIZER_ROOT=${KB_SUMMARIZER_ROOT:-/tmp/kb-summarizer}

mkdir -p "${KB_SUMMARIZER_ROOT}"/{input,output}
if ! tar -C "${KB_SUMMARIZER_ROOT}"/input \
         -xvf "${SONOBUOY_OUTPUT_FILE}" \
         --warning=no-timestamp
then
  echo "error extracting ${SONOBUOY_OUTPUT_FILE}"
  exit 1
fi

PLUGIN_NAME=${PLUGIN_NAME:-rancher-kube-bench}
KBS_INPUT_DIR=${KB_SUMMARIZER_ROOT}/input/plugins/${PLUGIN_NAME}/results
KBS_OUTPUT_DIR=${KB_SUMMARIZER_ROOT}/output
KBS_OUTPUT_FILENAME=output.json

get_k8s_api_version() {
  KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)
  api_version=$(curl -sSk \
  -H "Authorization: Bearer $KUBE_TOKEN" \
  "https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_PORT_443_TCP_PORT}/version" | jq -r '.major + "." +.minor')
  echo "${api_version}"
}

if [[ "${RANCHER_K8S_VERSION}" == "" ]]; then
  K8S_API_VERSION=$(get_k8s_api_version)
  RANCHER_K8S_VERSION="rke-${K8S_API_VERSION}"
  echo "Calculated Rancher Kubernetes Version: ${RANCHER_K8S_VERSION}"
else
  echo "Provided Rancher Kubernetes Version: ${RANCHER_K8S_VERSION}"
fi

if [[ -f "${KBS_CONFIG_FILE_LOCATION}" ]]; then
  echo "using skip config from configmap"
  export SKIP_CONFIG_FILE="${KBS_CONFIG_FILE_LOCATION}"
fi


# Env Vars:
#   - SKIP_CONFIG_FILE
if [[ "${OVERRIDE_BENCHMARK_VERSION}" != "" ]]; then
  echo "using OVERRIDE_BENCHMARK_VERSION: ${OVERRIDE_BENCHMARK_VERSION}"
  if ! kb-summarizer \
        --benchmark-version "${OVERRIDE_BENCHMARK_VERSION}" \
        --input-dir "${KBS_INPUT_DIR}" \
        --output-dir "${KBS_OUTPUT_DIR}" \
        --output-filename "${KBS_OUTPUT_FILENAME}"
  then
    echo "error running kb-summarizer"
    handle_error
  fi
else
  if ! kb-summarizer \
        --k8s-version "${RANCHER_K8S_VERSION}" \
        --input-dir "${KBS_INPUT_DIR}" \
        --output-dir "${KBS_OUTPUT_DIR}" \
        --output-filename "${KBS_OUTPUT_FILENAME}"
  then
    echo "error running kb-summarizer"
    handle_error
  fi
fi

# Create a config map with results
if ! kubectl -n "${SONOBUOY_NS}" \
  create cm  "${OUTPUT_CONFIGMAPNAME}" \
  --from-file "${KBS_OUTPUT_DIR}"/${KBS_OUTPUT_FILENAME}
then
  echo "error creating configmap for storing the report"
  handle_error
fi

if [[ "${DEBUG}" == "true" ]]; then
    sleep "${DEBUG_TIME_IN_SEC}"
fi

# Annotate self (pod) to signal "done"
if ! kubectl -n "${SONOBUOY_NS}" \
  annotate pod "${SONOBUOY_POD_NAME}" \
  ${DONE_ANNOTATION_KEY}=${DONE_ANNOTATION_VALUE}
then
  echo "error annotating self pod"
  handle_error
fi

# Wait
# The controller will remove this chart once the done annotation is detected
sleep infinity
