# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.31.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint
GOLANGCI_VERSION = v2.11.4
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.11.4
GOLANGCI_SUM_amd64=200c5b7503f67b59a6743ccf32133026c174e272b930ee79aa2aa6f37aca7ef1
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.11.4
GOLANGCI_SUM_arm64=3bcfa2e6f3d32b2bf5cd75eaa876447507025e0303698633f722a05331988db4

# The kube-bench, sonobuoy and kubectl binaries come from the cowboy-builder RPM
# packages (see package/Dockerfile). The versions below only define the kube-bench
# config files and tooling, the sonobuoy image and the kind cluster of the e2e tests.
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench
KUBE_BENCH_VERSION ?= v0.16.0

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy
SONOBUOY_VERSION ?= v0.57.5
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:$(SONOBUOY_VERSION)

# renovate: datasource=github-release-attachments depName=kubernetes/kubectl
KUBECTL_VERSION ?= 1.35.9

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION)