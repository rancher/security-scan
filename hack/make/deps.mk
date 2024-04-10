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
SONOBUOY_VERSION ?= v0.57.0
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:$(SONOBUOY_VERSION)

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.0
SONOBUOY_SUM_arm64 ?= 75c6f1d590ade2de2fbe59d53ff8005ff99d31517f2f12a6a36a03573f7e73c3
# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.0
SONOBUOY_SUM_amd64 ?= f9006ed997fd5a701b34a96786efffa52d5e77873bfc717bc252c2e5ef8a7f3c

KUBECTL_VERSION ?= 1.28.7
KUBECTL_SUM_arm64 ?= $(shell curl -L "https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/linux/arm64/kubectl.sha256")
KUBECTL_SUM_amd64 ?= $(shell curl -L "https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/linux/amd64/kubectl.sha256")

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
			  --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
			  --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)
