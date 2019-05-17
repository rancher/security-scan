#!/bin/bash

set -x

echo "Rancher: Running CIS Benchmarks"

# Run sonobuoy first
sonobuoy master -v 3
if [ $? -ne 0 ]; then
  echo "error running sonobuoy"
  exit 1
fi

# This is hardcoded in the tool itself
SONOBUOY_NS=heptio-sonobuoy
SONOBUOY_POD_NAME=sonobuoy

DONE_ANNOTATION_KEY="field.cattle.io/sonobuoyDone"
DONE_ANNOTATION_VALUE="true"

# Run summarizer
SONOBUOY_OUTPUT_DIR=${SONOBUOY_OUTPUT_DIR:-/tmp/sonobuoy}
SONOBUOY_OUTPUT_FILE=$(ls -1 ${SONOBUOY_OUTPUT_DIR}/*.tar.gz)

KUBE_BENCH_SUMMARIZER_ROOT=${KUBE_BENCH_SUMMARIZER_ROOT:-/tmp/kube-bench-summarizer}

mkdir -p ${KUBE_BENCH_SUMMARIZER_ROOT}/{input,output}
tar -C ${KUBE_BENCH_SUMMARIZER_ROOT}/input -xvf ${SONOBUOY_OUTPUT_FILE} --warning=no-timestamp

PLUGIN_NAME=${PLUGIN_NAME:-rancher-kube-bench}
KBS_INPUT_DIR=${KUBE_BENCH_SUMMARIZER_ROOT}/input/plugins/${PLUGIN_NAME}/results
KBS_OUTPUT_DIR=${KUBE_BENCH_SUMMARIZER_ROOT}/output
KBS_OUPTPUT_FILENAME=report.json

kube-bench-summarizer --input-dir ${KBS_INPUT_DIR} --output-dir ${KBS_OUTPUT_DIR}
if [ $? -ne 0 ]; then
  echo "error running kube-bench-summarizer"
  exit 1
fi

# Create a config map with results
kubectl -n ${SONOBUOY_NS} \
  create cm cis-$(date +"%Y-%m-%d-%H-%M-%S-%N") \
  --from-file ${KBS_OUTPUT_DIR}/${KBS_OUPTPUT_FILENAME}
if [ $? -ne 0 ]; then
  echo "error creating configmap for storing the report"
  exit 1
fi

# Annotate self (pod) to signal "done"
kubectl -n ${SONOBUOY_NS} \
  annotate pod ${SONOBUOY_POD_NAME} \
  ${DONE_ANNOTATION_KEY}=${DONE_ANNOTATION_VALUE}

# Wait
sleep infinity
