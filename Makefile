# To avoid poluting the Makefile, versions and checksums for tooling and 
# dependencies are defined at hack/make/deps.mk.
include hack/make/deps.mk

# Include logic that can be reused across projects.
include hack/make/build.mk
include hack/make/tools.mk

# Define target platforms, image builder and the fully qualified image name.
TARGET_PLATFORMS ?= linux/amd64,linux/arm64

REPO ?= rancher
IMAGE = $(REPO)/security-scan:$(TAG)
TARGET_BIN ?= build/bin/kb-summarizer
ARCH ?= $(shell docker info --format '{{.ClientInfo.Arch}}')
BUILD_ACTION = --load

.DEFAULT_GOAL := ci
ci: build test validate e2e ## run the targets needed to validate a PR in CI.

clean: ## clean up project.
	rm -rf bin build

test: ## run unit tests.
	@echo "Running tests"
	go test -race -cover ./...

.PHONY: build
build: # build project and output binary to TARGET_BIN.
	CGO_ENABLED=0 $(GO) build -trimpath -ldflags "-X main.VERSION=$(VERSION) $(LINKFLAGS)" -o $(TARGET_BIN) ./cmd/kb-summarizer/
	$(TARGET_BIN) --version
	md5sum $(TARGET_BIN)

test-image: buildx-machine ## build the container image for all target architecures.
	# Instead of loading image, target all platforms, effectivelly testing
	# the build for the target architectures.
	$(MAKE) build-image BUILD_ACTION="--platform=$(TARGET_PLATFORMS)"

.PHONY: build-image
build-image: buildx-machine ## build (and load) the container image targeting the current platform.
	$(IMAGE_BUILDER) build -f package/Dockerfile \
		--builder $(MACHINE) $(IMAGE_ARGS) \
		--build-arg VERSION=$(VERSION) -t "$(IMAGE)" $(BUILD_ACTION) .
	@echo "Built $(IMAGE)"

.PHONY: push-image
push-image: buildx-machine ## build the container image targeting all platforms defined by TARGET_PLATFORMS and push to a registry.
	$(IMAGE_BUILDER) build -f package/Dockerfile \
		--builder $(MACHINE) $(IMAGE_ARGS) $(IID_FILE_FLAG) $(BUILDX_ARGS) \
		--build-arg VERSION=$(VERSION) --platform=$(TARGET_PLATFORMS) -t "$(IMAGE)" --push .
	@echo "Pushed $(IMAGE)"

e2e: $(KIND) build-image ## run E2E tests.
	@KUBERNETES_VERSION=$(KUBERNETES_VERSION) IMAGE=$(IMAGE) \
	SONOBUOY_IMAGE=$(SONOBUOY_IMAGE) ARCH=$(ARCH) \
	./hack/e2e

validate: validate-go validate-yaml ## run validation checks.

validate-yaml: yamllint $(KUBE_BENCH)
	@PATH=$(PATH):$(TOOLS_BIN) \
	./hack/validate-yaml

validate-go: $(GOIMPORTS) $(GOLANGCI_LINT)
	@PATH=$(PATH):$(TOOLS_BIN) \
	./hack/validate-go
