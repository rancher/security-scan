# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.30.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint
GOLANGCI_VERSION = v2.11.4
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.11.4
GOLANGCI_SUM_amd64=200c5b7503f67b59a6743ccf32133026c174e272b930ee79aa2aa6f37aca7ef1
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.11.4
GOLANGCI_SUM_arm64=3bcfa2e6f3d32b2bf5cd75eaa876447507025e0303698633f722a05331988db4

KUBE_BENCH_VERSION ?= v0.15.6
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.15.6
KUBE_BENCH_SUM_arm64 ?= 69a3870f5ce3578429de8d5d771b7703a062eec64b8d7e6d014b15350fcb4a35
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.15.6
KUBE_BENCH_SUM_amd64 ?= 783882d23a13837ffd9d2a3dc713d86bed121802f51c93465f47add4dae9eb23

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy
SONOBUOY_VERSION ?= v0.57.3
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:$(SONOBUOY_VERSION)

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.3
SONOBUOY_SUM_arm64 ?= 958edd774ff6a23f8eaefc2ea2c361b05caa8d7980ab8443e552e7f7bf100ab1
# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.3
SONOBUOY_SUM_amd64 ?= 6728e04f62068465c56e2d317f4a5392520bf00c836aeaba970ae913f943718c

# renovate: datasource=github-release-attachments depName=kubernetes/kubectl
KUBECTL_VERSION ?= 1.34.8
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=v1.34.8
KUBECTL_SUM_arm64 ?= 4c9fe1f717738950c638c38056130a8db5075e6413ae36d8687221a240cdf88b
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=v1.34.8
KUBECTL_SUM_amd64 ?= f6249132865c13abe3c9dd5038f5da65849cb86eee1608c001831504e481aa8c

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
              --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
              --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)

