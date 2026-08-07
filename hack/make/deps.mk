# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.29.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint
GOLANGCI_VERSION = v2.11.4
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.11.4
GOLANGCI_SUM_amd64=200c5b7503f67b59a6743ccf32133026c174e272b930ee79aa2aa6f37aca7ef1
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.11.4
GOLANGCI_SUM_arm64=3bcfa2e6f3d32b2bf5cd75eaa876447507025e0303698633f722a05331988db4

# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench
KUBE_BENCH_VERSION ?= v0.16.0
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.16.0
KUBE_BENCH_SUM_arm64 ?= 64500561f5fcaa3f86fe951ed26bbfc28f7bbf3d2eac13843abfd2924955d10b
# renovate: datasource=github-release-attachments depName=aquasecurity/kube-bench digestVersion=v0.16.0
KUBE_BENCH_SUM_amd64 ?= 82dbc7e598740dc9344d41f8ad0b8210d57c4c00bdb2c5f1d8a69a2b98baddcf

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy
SONOBUOY_VERSION ?= v0.57.5
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:$(SONOBUOY_VERSION)

# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.5
SONOBUOY_SUM_arm64 ?= ec482b5d1ec237f4c94b6fd7be5a69f95678a4331001b3edcb6ad7835ec40695
# renovate: datasource=github-release-attachments depName=vmware-tanzu/sonobuoy digestVersion=v0.57.5
SONOBUOY_SUM_amd64 ?= 7c5c2250e5103c98f4dad2bcab86baf954e319c57c419c113f28f5060e62f129

# renovate: datasource=github-release-attachments depName=kubernetes/kubectl
KUBECTL_VERSION ?= 1.33.13
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=1.33.13
KUBECTL_SUM_arm64 ?= 9fe8aadd5aab9421978c7ac95de6fad304a3c4c0ce9dbf4127579779e0699080
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=1.33.13
KUBECTL_SUM_amd64 ?= 316d712726d857c20744c57cb36aa47cfc79bc0af7e82cebf3780244b654c073

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
              --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
              --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)
