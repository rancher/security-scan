#!/bin/bash

set -x

echo "Rancher: Running CIS Benchmarks"

defaultCMName=cis-$(date +"%Y-%m-%d-%H-%M-%S-%N")
CONFIGMAPNAME=${CONFIGMAPNAME:-${defaultCMName}}

# Run sonobuoy first
if ! sonobuoy master -v 3
then
  echo "error running sonobuoy"
  exit 1
fi

# This is hardcoded in the tool itself
SONOBUOY_NS=${SONOBUOY_NS:-sonobuoy}
SONOBUOY_POD_NAME=${SONOBUOY_POD_NAME:-sonobuoy}

DONE_ANNOTATION_KEY="field.cattle.io/sonobuoyDone"
DONE_ANNOTATION_VALUE="true"

# Run summarizer
SONOBUOY_OUTPUT_DIR=${SONOBUOY_OUTPUT_DIR:-/tmp/sonobuoy}
SONOBUOY_OUTPUT_FILE=$(ls -1 "${SONOBUOY_OUTPUT_DIR}"/*.tar.gz)

KUBE_BENCH_SUMMARIZER_ROOT=${KUBE_BENCH_SUMMARIZER_ROOT:-/tmp/kube-bench-summarizer}

mkdir -p "${KUBE_BENCH_SUMMARIZER_ROOT}"/{input,output}
if ! tar -C "${KUBE_BENCH_SUMMARIZER_ROOT}"/input \
         -xvf "${SONOBUOY_OUTPUT_FILE}" \
         --warning=no-timestamp
then
  echo "error extracting ${SONOBUOY_OUTPUT_FILE}"
  exit 1
fi

PLUGIN_NAME=${PLUGIN_NAME:-rancher-kube-bench}
KBS_INPUT_DIR=${KUBE_BENCH_SUMMARIZER_ROOT}/input/plugins/${PLUGIN_NAME}/results
KBS_OUTPUT_DIR=${KUBE_BENCH_SUMMARIZER_ROOT}/output
KBS_OUPTPUT_FILENAME=report.json

KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)
K8S_API_VERSION=$(curl -sSk \
-H "Authorization: Bearer $KUBE_TOKEN" \
"https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_PORT_443_TCP_PORT}/version" | jq -r '.major + "." +.minor')

RANCHER_K8S_VERSION="rke-${K8S_API_VERSION}"
echo "Rancher Kubernetes Version: ${RANCHER_K8S_VERSION}"

if ! kube-bench-summarizer \
      --k8s-version "${RANCHER_K8S_VERSION}" \
      --input-dir "${KBS_INPUT_DIR}" \
      --output-dir "${KBS_OUTPUT_DIR}"
then
  echo "error running kube-bench-summarizer"
  exit 1
fi

# Create a config map with results
if ! kubectl -n "${SONOBUOY_NS}" \
  create cm  "${CONFIGMAPNAME}" \
  --from-file "${KBS_OUTPUT_DIR}"/${KBS_OUPTPUT_FILENAME}
then
  echo "error creating configmap for storing the report"
  exit 1
fi

# Annotate self (pod) to signal "done"
if ! kubectl -n "${SONOBUOY_NS}" \
  annotate pod ${SONOBUOY_POD_NAME} \
  ${DONE_ANNOTATION_KEY}=${DONE_ANNOTATION_VALUE}
then
  echo "error annotating self pod"
  exit 1
fi

# Wait
# The controller will remove this chart once the done annotation is detected
sleep infinity
