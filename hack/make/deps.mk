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
KUBE_BENCH_VERSION ?= v0.15.4
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.15.4
KUBE_BENCH_SUM_arm64 ?= 58504862a53ccf56c416484ce9f0fa951b882b316efe32c4356de2ed6da62bc6
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.15.4
KUBE_BENCH_SUM_amd64 ?= 7ff96e2a5056e61a8f9aa6d0d64c9eb90e78968e67b66252b6f9ca4faea2d029
# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy
SONOBUOY_VERSION ?= v0.57.3
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:$(SONOBUOY_VERSION)

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.3
SONOBUOY_SUM_arm64 ?= 958edd774ff6a23f8eaefc2ea2c361b05caa8d7980ab8443e552e7f7bf100ab1
# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.3
SONOBUOY_SUM_amd64 ?= 6728e04f62068465c56e2d317f4a5392520bf00c836aeaba970ae913f943718c

# renovate: datasource=github-release-attachments depName=kubernetes/kubectl
KUBECTL_VERSION ?= 1.35.2
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=v1.35.2
KUBECTL_SUM_arm64 ?= cd859449f54ad2cb05b491c490c13bb836cdd0886ae013c0aed3dd67ff747467
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=v1.35.2
KUBECTL_SUM_amd64 ?= 924eb50779153f20cb668117d141440b95df2f325a64452d78dff9469145e277

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
              --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
              --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)
