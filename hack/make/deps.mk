# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.32.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint
GOLANGCI_VERSION = v2.13.1
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.13.1
GOLANGCI_SUM_amd64=b17bfbc9d4aaa48be7f4f1ce3240bc3d8200c870c072bacf15c26219e2cfb9cc
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.13.1
GOLANGCI_SUM_arm64=908317c23db18448f924e853b3d8a659fd919614cd438f224810a4053daa2607

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
KUBECTL_VERSION ?= 1.36.3
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=v1.36.3
KUBECTL_SUM_arm64 ?= 3d86f24401c41ae5a46ac50eef8865fe891d3647d324a0836f6c63757a126e62
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=v1.36.3
KUBECTL_SUM_amd64 ?= ebbd080e7c2e275093b55915722043257eb24004363e20acb3c4d71919f88336

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
              --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
              --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)
