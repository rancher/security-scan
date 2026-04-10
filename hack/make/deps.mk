# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.30.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint
GOLANGCI_VERSION = v2.5.0
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.5.0
GOLANGCI_SUM_amd64=c77313a77e19b06123962c411d9943cc0d092bbec76b956104d18964e274902e
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.5.0
GOLANGCI_SUM_arm64=48693a98a7f4556d1117300aae240d0fe483df8d6f36dfaba56504626101a66e

# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench
KUBE_BENCH_VERSION ?= v0.14.1
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.14.1
KUBE_BENCH_SUM_arm64 ?= 4450dcd502a2f8647c8cc9d5dfe09cd310ff42f28c953d001bffc534f7d09fd0
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.14.1
KUBE_BENCH_SUM_amd64 ?= 73312e994bc2011b90ba1491f41cfeb440439b7923b6e2562027cbf573121963

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy
SONOBUOY_VERSION ?= v0.57.3
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:$(SONOBUOY_VERSION)

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.3
SONOBUOY_SUM_arm64 ?= 958edd774ff6a23f8eaefc2ea2c361b05caa8d7980ab8443e552e7f7bf100ab1
# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.3
SONOBUOY_SUM_amd64 ?= 6728e04f62068465c56e2d317f4a5392520bf00c836aeaba970ae913f943718c

# renovate: datasource=github-release-attachments depName=kubernetes/kubectl
KUBECTL_VERSION ?= 1.34.3
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=v1.34.3
KUBECTL_SUM_arm64 ?= 46913a7aa0327f6cc2e1cc2775d53c4a2af5e52f7fd8dacbfbfd098e757f19e9
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=v1.34.3
KUBECTL_SUM_amd64 ?= ab60ca5f0fd60c1eb81b52909e67060e3ba0bd27e55a8ac147cbc2172ff14212

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
              --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
              --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)

