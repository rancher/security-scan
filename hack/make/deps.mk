# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.31.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint
GOLANGCI_VERSION = v2.12.2
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.12.2
GOLANGCI_SUM_amd64=8df580d2670fed8fa984aac0507099af8df275e665215f5c7a2ae3943893a553
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.12.2
GOLANGCI_SUM_arm64=44cd40a8c76c86755375adfeea52cfd3533cb43d7bd647771e0ae065e166df3a

# The kube-bench, sonobuoy and kubectl binaries come from the cowboy-builder RPM
# packages (see package/Dockerfile). The versions below only define the kube-bench
# config files and tooling, the sonobuoy image and the kind cluster of the e2e tests.
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench
KUBE_BENCH_VERSION ?= v0.16.0

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy
SONOBUOY_VERSION ?= v0.57.5
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:$(SONOBUOY_VERSION)

# renovate: datasource=github-release-attachments depName=kubernetes/kubectl
KUBECTL_VERSION ?= 1.36.5

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION)
