# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.31.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint
GOLANGCI_VERSION = v2.12.2
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.12.2
GOLANGCI_SUM_amd64=8df580d2670fed8fa984aac0507099af8df275e665215f5c7a2ae3943893a553
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.12.2
GOLANGCI_SUM_arm64=44cd40a8c76c86755375adfeea52cfd3533cb43d7bd647771e0ae065e166df3a

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
KUBECTL_VERSION ?= 1.36.0
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=v1.36.0
KUBECTL_SUM_arm64 ?= 9f9d9c44a7b5264515ac9da5991584e2395bd50662e651132337e7b4d0c56f8f
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=v1.36.0
KUBECTL_SUM_amd64 ?= 123d8c8844f46b1244c547fffb3c17180c0c26dac9890589fe7e67763298748e

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
              --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
              --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)
