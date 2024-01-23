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
		--builder $(MACHINE) $(IMAGE_ARGS) -t "$(IMAGE)" --load .
	@echo "Built $(IMAGE)"

.PHONY: image-push
image-push: buildx-machine ## build the container image targeting all platforms defined by TARGET_PLATFORMS and push to a registry.
	$(IMAGE_BUILDER) build -f package/Dockerfile \
		--builder $(MACHINE) $(IMAGE_ARGS) $(IID_FILE_FLAG) $(BUILDX_ARGS) \
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
