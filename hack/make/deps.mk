# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.27.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench
KUBE_BENCH_VERSION ?= v0.10.1
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.10.1
KUBE_BENCH_SUM_arm64 ?= 7965b43077d6d6aef26b210e0e005e6030b748766aba8dfa658ac16ec1cfe7c9
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.10.1
KUBE_BENCH_SUM_amd64 ?= 65f836ef3da190d44849e12b9f55a62bbf8c79c9178cae2514644dcb5108e530

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy
SONOBUOY_VERSION ?= v0.57.2
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:$(SONOBUOY_VERSION)

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.2
SONOBUOY_SUM_arm64 ?= 2ecfb9f8d2c5f20f48600eb9aabf9416b03ad598ebe05c89d8731eceb83cba1a
# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.2
SONOBUOY_SUM_amd64 ?= 83e9fdd9293066b2793a2b31a3f12517f8c8318a149223515cef6bdc3a2d587c

KUBECTL_VERSION ?= 1.29.10
KUBECTL_SUM_arm64 ?= $(shell curl -L "https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/linux/arm64/kubectl.sha256")
KUBECTL_SUM_amd64 ?= $(shell curl -L "https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/linux/amd64/kubectl.sha256")

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
			  --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
			  --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)
