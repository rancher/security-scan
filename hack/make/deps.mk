# renovate: datasource=github-release-attachments depName=kubernetes-sigs/kind
KIND_VERSION ?= 0.29.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

# renovate: datasource=github-release-attachments depName=golangci/golangci-lint
GOLANGCI_VERSION = v2.8.0
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.8.0
GOLANGCI_SUM_amd64=7048bc6b25c9515ed092c83f9fa8709ca97937ead52d9ff317a143299ee97a50
# renovate: datasource=github-release-attachments depName=golangci/golangci-lint digestVersion=v2.8.0
GOLANGCI_SUM_arm64=2a58388db8af5ab9330791cea0ebdd4100723cd05ad7185d92febaaee272ec9a

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
KUBECTL_VERSION ?= 1.33.7
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=1.33.7
KUBECTL_SUM_arm64 ?= fa7ee98fdb6fba92ae05b5e0cde0abd5972b2d9a4a084f7052a1fd0dce6bc1de
# renovate: datasource=github-release-attachments depName=kubernetes/kubectl digestVersion=1.33.7
KUBECTL_SUM_amd64 ?= 471d94e208a89be62eb776700fc8206cbef11116a8de2dc06fc0086b0015375b

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
              --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
              --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)
