# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.22.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench
KUBE_BENCH_VERSION ?= v0.7.0
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.7.0
KUBE_BENCH_SUM_arm64 ?= 53da250a3211d717378e6ef37ee541d2cd212953628b064f2f7e2ca8a5a7bb57
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.7.0
KUBE_BENCH_SUM_amd64 ?= e9ede7c6f3570cf8f4e81925cd2523fc9c3442fb8304477637f231c7b4647e7d

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy
SONOBUOY_VERSION ?= v0.57.1
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:$(SONOBUOY_VERSION)

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.1
SONOBUOY_SUM_arm64 ?= b6665011ae337e51cd6032ebfc37a6818dc8481c6cf6f2692e109a08be908e49
# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.1
SONOBUOY_SUM_amd64 ?= 0fd3ae735ee25b6b37b713aadd4a836b53aa2b82c8e6ecad0c2359de046f8212

KUBECTL_VERSION ?= 1.28.7
KUBECTL_SUM_arm64 ?= $(shell curl -L "https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/linux/arm64/kubectl.sha256")
KUBECTL_SUM_amd64 ?= $(shell curl -L "https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/linux/amd64/kubectl.sha256")

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
			  --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
			  --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)
