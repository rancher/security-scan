# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.31.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint
GOLANGCI_VERSION = v2.11.4
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.11.4
GOLANGCI_SUM_amd64=200c5b7503f67b59a6743ccf32133026c174e272b930ee79aa2aa6f37aca7ef1
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.11.4
GOLANGCI_SUM_arm64=3bcfa2e6f3d32b2bf5cd75eaa876447507025e0303698633f722a05331988db4

# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench
KUBE_BENCH_VERSION ?= v0.15.6
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.15.6
KUBE_BENCH_SUM_arm64 ?= 69a3870f5ce3578429de8d5d771b7703a062eec64b8d7e6d014b15350fcb4a35
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.15.6
KUBE_BENCH_SUM_amd64 ?= 783882d23a13837ffd9d2a3dc713d86bed121802f51c93465f47add4dae9eb23

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy
SONOBUOY_VERSION ?= v0.57.5
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:$(SONOBUOY_VERSION)

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.5
SONOBUOY_SUM_arm64 ?= ec482b5d1ec237f4c94b6fd7be5a69f95678a4331001b3edcb6ad7835ec40695
# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.5
SONOBUOY_SUM_amd64 ?= 7c5c2250e5103c98f4dad2bcab86baf954e319c57c419c113f28f5060e62f129

# renovate: datasource=github-release-attachments depName=kubernetes/kubectl
KUBECTL_VERSION ?= 1.35.6
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=v1.35.6
KUBECTL_SUM_arm64 ?= c0f97f31c9ddc22d4951d543a1a7125a9af4b31e895ad4aa99899c4ba2a6ff0b
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=v1.35.6
KUBECTL_SUM_amd64 ?= 5d11e2ba01ea68ffd053f56e27738e2b4330013ee67f7e46c6da6c585d3c9926

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
			  --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
			  --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)