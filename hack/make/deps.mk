# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.33.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint
GOLANGCI_VERSION = v2.14.0
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.14.0
GOLANGCI_SUM_amd64=ab90aeb7b066f92a33415b638a50fe5344bbb75a0d32ad30cc248d88f81032ab
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.14.0
GOLANGCI_SUM_arm64=ee7ec5f3453d15ddf106fae5a4d6c71737712348a979d1fe9cd52ec7ea299bae

# The kube-bench, sonobuoy and kubectl binaries come from the cowboy-builder RPM
# packages (see package/Dockerfile). The versions below only define the kube-bench
# config files and tooling, the sonobuoy image and the kind cluster of the e2e tests.
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench
KUBE_BENCH_VERSION ?= v0.16.0
# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy
SONOBUOY_VERSION ?= v0.57.5
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:$(SONOBUOY_VERSION)

# renovate: datasource=github-release-attachments depName=kubernetes/kubectl
KUBECTL_VERSION ?= 1.37.1

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION)
