# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.31.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint
GOLANGCI_VERSION = v2.10.1

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.10.1
GOLANGCI_SUM_amd64 := dfa775874cf0561b404a02a8f4481fc69b28091da95aa697259820d429b09c99
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.10.1
GOLANGCI_SUM_arm64 := 6652b42ae02915eb2f9cb2a2e0cac99514c8eded8388d88ae3e06e1a52c00de8

# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench
KUBE_BENCH_VERSION ?= v0.15.0
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.15.0
KUBE_BENCH_SUM_arm64 ?= e38362567fd6d42b1c230cd2880a650c055dc0f10bc41cbf5b386cbcb29b2f51
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.15.0
KUBE_BENCH_SUM_amd64 ?= 29cf96002be26fd0e27f80e19747b5dc06879bcbefdd6f34fe0f31418db34b14

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy
SONOBUOY_VERSION ?= v0.57.3
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:$(SONOBUOY_VERSION)

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.3
SONOBUOY_SUM_arm64 ?= 958edd774ff6a23f8eaefc2ea2c361b05caa8d7980ab8443e552e7f7bf100ab1
# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.3
SONOBUOY_SUM_amd64 ?= 6728e04f62068465c56e2d317f4a5392520bf00c836aeaba970ae913f943718c

KUBECTL_VERSION ?= 1.35.2
KUBECTL_SUM_arm64 ?= cd859449f54ad2cb05b491c490c13bb836cdd0886ae013c0aed3dd67ff747467
KUBECTL_SUM_amd64 ?= 924eb50779153f20cb668117d141440b95df2f325a64452d78dff9469145e277

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
			  --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
			  --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)

# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.15.0
KUBE_BENCH_CFG_SUM_arm64 ?= 7d9e894863998800a57cc5045a62dd5b7e958951347f172a96aea0907f200b19
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.15.0
KUBE_BENCH_CFG_SUM_amd64 ?= 7d9e894863998800a57cc5045a62dd5b7e958951347f172a96aea0907f200b19