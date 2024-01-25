KIND_VERSION ?= 0.17.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)

KUBE_BENCH_VERSION ?= 0.7.0
# github release / kube-bench_${KUBE_BENCH_VERSION}_checksums.txt
KUBE_BENCH_SUM_arm64 ?= 53da250a3211d717378e6ef37ee541d2cd212953628b064f2f7e2ca8a5a7bb57
KUBE_BENCH_SUM_amd64 ?= e9ede7c6f3570cf8f4e81925cd2523fc9c3442fb8304477637f231c7b4647e7d

SONOBUOY_VERSION ?= 0.57.0
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:v$(SONOBUOY_VERSION)

# github release / sonobuoy_${SONOBUOY_VERSION}_checksums.txt
SONOBUOY_SUM_arm64 ?= 75c6f1d590ade2de2fbe59d53ff8005ff99d31517f2f12a6a36a03573f7e73c3
SONOBUOY_SUM_amd64 ?= f9006ed997fd5a701b34a96786efffa52d5e77873bfc717bc252c2e5ef8a7f3c

KUBECTL_VERSION ?= 1.28.0
# curk -L "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/arm64/kubectl.sha256"
KUBECTL_SUM_arm64 ?= f5484bd9cac66b183c653abed30226b561f537d15346c605cc81d98095f1717c
# curk -L "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl.sha256"
KUBECTL_SUM_amd64 ?= 4717660fd1466ec72d59000bb1d9f5cdc91fac31d491043ca62b34398e0799ce

# Reduces the code duplication on Makefile by keeping all args into a single variable.
IMAGE_ARGS := --build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) --build-arg SONOBUOY_SUM_arm64=$(SONOBUOY_SUM_arm64) --build-arg SONOBUOY_SUM_amd64=$(SONOBUOY_SUM_amd64) \
			  --build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) --build-arg KUBE_BENCH_SUM_arm64=$(KUBE_BENCH_SUM_arm64) --build-arg KUBE_BENCH_SUM_amd64=$(KUBE_BENCH_SUM_amd64) \
			  --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) --build-arg KUBECTL_SUM_arm64=$(KUBECTL_SUM_arm64) --build-arg KUBECTL_SUM_amd64=$(KUBECTL_SUM_amd64)
