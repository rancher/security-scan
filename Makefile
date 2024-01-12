# The versions of any needed tooling/dependency should be defined here.
KIND_VERSION ?= 0.17.0
KUBECTL_VERSION ?= 1.28.0
KUBERNETES_VERSION ?= v$(KUBECTL_VERSION)
KUBE_BENCH_VERSION ?= 0.7.0
SONOBUOY_VERSION ?= 0.57.0
SONOBUOY_IMAGE ?= rancher/mirrored-sonobuoy-sonobuoy:v$(SONOBUOY_VERSION)

# Include logic that can be reused across projects.
include hack/make/build.mk
include hack/make/tools.mk

# Define target platforms, image builder and the fully qualified image name.
TARGET_PLATFORMS ?= linux/amd64,linux/arm64

REPO ?= rancher
IMAGE = $(REPO)/security-scan:$(TAG)
TARGET_BIN ?= build/bin/kb-summarizer
ARCH ?= $(shell docker info --format '{{.ClientInfo.Arch}}')

.DEFAULT_GOAL := ci
ci: build test validate e2e ## run the targets needed to validate a PR in CI.

clean: ## clean up project.
	rm -rf bin build

test: ## run unit tests.
	@echo "Running tests"
	go test -race -cover ./...

.PHONY: build
build: # build project and output binary to TARGET_BIN.
	CGO_ENABLED=0 $(GO) build -ldflags "-X main.VERSION=$(VERSION) $(LINKFLAGS)" -o $(TARGET_BIN) ./cmd/kb-summarizer/
	$(TARGET_BIN) --version
	md5sum $(TARGET_BIN)

.PHONY: image-build
image-build: buildx-machine ## build (and load) the container image targeting the current platform.
	$(IMAGE_BUILDER) build -f package/Dockerfile \
		--builder $(MACHINE) \
		--build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) \
		--build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) \
		--build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) \
		-t "$(IMAGE)" --load .
	@echo "Built $(IMAGE)"

.PHONY: image-push
image-push: buildx-machine ## build the container image targeting all platforms defined by TARGET_PLATFORMS and push to a registry.
	$(IMAGE_BUILDER) build -f package/Dockerfile \
		--builder $(MACHINE) \
		--build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) \
		--build-arg SONOBUOY_VERSION=$(SONOBUOY_VERSION) \
		--build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) $(IID_FILE_FLAG) $(BUILDX_ARGS) \
		--platform=$(TARGET_PLATFORMS) -t "$(IMAGE)" --push .
	@echo "Pushed $(IMAGE)"

e2e: $(KIND) image-build ## run E2E tests.
	@KUBERNETES_VERSION=$(KUBERNETES_VERSION) IMAGE=$(IMAGE) \
	SONOBUOY_IMAGE=$(SONOBUOY_IMAGE) ARCH=$(ARCH) \
	./hack/e2e

validate: validate-go validate-yaml ## run validation checks.

validate-yaml: yamllint $(KUBE_BENCH)
	@PATH=$(PATH):$(TOOLS_BIN) \
	./hack/validate-yaml

validate-go: $(GOIMPORTS) $(GOLINT)
	@PATH=$(PATH):$(TOOLS_BIN) \
	./hack/validate-go
