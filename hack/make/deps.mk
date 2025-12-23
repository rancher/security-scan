# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.31.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint
GOLANGCI_VERSION = v2.7.2

# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench
KUBE_BENCH_VERSION ?= v0.14.0
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.14.0
KUBE_BENCH_SUM_arm64 ?= ccbcc634a8603b8b72603c3824b6142abb551321847a9b987ea505e7f206cc66
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.14.0
KUBE_BENCH_SUM_amd64 ?= f35b716b1837d9fd40fbb2bc986ddc9378094de27cacec6bede58a7be81158ad

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy
SONOBUOY_VERSION ?= v0.57.3
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:$(SONOBUOY_VERSION)

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.3
SONOBUOY_SUM_arm64 ?= 958edd774ff6a23f8eaefc2ea2c361b05caa8d7980ab8443e552e7f7bf100ab1
# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.3
SONOBUOY_SUM_amd64 ?= 6728e04f62068465c56e2d317f4a5392520bf00c836aeaba970ae913f943718c

KUBECTL_VERSION ?= 1.35.0
KUBECTL_SUM_arm64 ?= $(shell curl -L "https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/linux/arm64/kubectl.sha256")
KUBECTL_SUM_amd64 ?= $(shell curl -L "https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/linux/amd64/kubectl.sha256")

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
			  --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
			  --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)
