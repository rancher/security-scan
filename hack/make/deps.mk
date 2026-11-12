# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.33.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint
GOLANGCI_VERSION = v2.15.0
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.15.0
GOLANGCI_SUM_amd64=9b7fe6a6bf6334b98decf8d86b11415ea7889afdabdd1959fdce23af2a9ebcea
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.15.0
GOLANGCI_SUM_arm64=b4d8f17068b35ee6060cc2f69a16fb48740d706fbba81661c318649c114a6998

# The kube-bench, sonobuoy and kubectl binaries come from the cowboy-builder RPM
# packages (see package/Dockerfile). The versions below only define the kube-bench
# config files and tooling and the kind cluster of the e2e tests.
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench
KUBE_BENCH_VERSION ?= v0.16.0

# renovate: datasource=github-release-attachments depName=kubernetes/kubectl
KUBECTL_VERSION ?= 1.37.1

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION)
