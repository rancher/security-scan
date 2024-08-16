# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.24.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench
KUBE_BENCH_VERSION ?= v0.8.0
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.8.0
KUBE_BENCH_SUM_arm64 ?= 82256042da9d78bb1cf1726dc8c108459c3cdc34df6298349113f551bde0feff
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.8.0
KUBE_BENCH_SUM_amd64 ?= 8e8f083819678956b6c36623a6a0638741340397ffc209cd71a6b4907f2bb05e

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy
SONOBUOY_VERSION ?= v0.57.1
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:$(SONOBUOY_VERSION)

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.1
SONOBUOY_SUM_arm64 ?= b6665011ae337e51cd6032ebfc37a6818dc8481c6cf6f2692e109a08be908e49
# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.1
SONOBUOY_SUM_amd64 ?= 0fd3ae735ee25b6b37b713aadd4a836b53aa2b82c8e6ecad0c2359de046f8212

KUBECTL_VERSION ?= 1.28.12
KUBECTL_SUM_arm64 ?= $(shell curl -L "https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/linux/arm64/kubectl.sha256")
KUBECTL_SUM_amd64 ?= $(shell curl -L "https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/linux/amd64/kubectl.sha256")

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
			  --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
			  --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)
