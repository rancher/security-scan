# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.31.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint
GOLANGCI_VERSION = v2.8.0
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.8.0
GOLANGCI_SUM_amd64=7048bc6b25c9515ed092c83f9fa8709ca97937ead52d9ff317a143299ee97a50
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.8.0
GOLANGCI_SUM_arm64=2a58388db8af5ab9330791cea0ebdd4100723cd05ad7185d92febaaee272ec9a

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

# renovate: datasource=github-release-attachments depName=kubernetes/kubectl
KUBECTL_VERSION ?= 1.35.3
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=v1.35.3
KUBECTL_SUM_arm64 ?= 6f0cd088a82dde5d5807122056069e2fac4ed447cc518efc055547ae46525f14
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=v1.35.3
KUBECTL_SUM_amd64 ?= fd31c7d7129260e608f6faf92d5984c3267ad0b5ead3bced2fe125686e286ad6

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
			  --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
			  --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)