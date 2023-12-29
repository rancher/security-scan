# The versions of any tooling should be defined here.
KIND_VERSION ?= 0.17.0
KUBERNETES_VERSION ?= 1.28.0
KUBE_BENCH_VERSION ?= 0.6.19

# Define VERSION, which is baked into the compiled binary to enable the
# printing of the application version - via flag --version.
CHANGES = $(shell git status --porcelain --untracked-files=no)
ifneq ($(CHANGES),)
    DIRTY = -dirty
endif

# Prioritise DRONE_TAG for backwards compatibility. However, the git tag
# command should be able to gather the current tag, except when the git
# clone operation was done with "--no-tags".
ifneq ($(DRONE_TAG),)
	GIT_TAG = $(DRONE_TAG)
else
	GIT_TAG = $(shell git tag -l --contains HEAD | head -n 1)
endif

COMMIT = $(shell git rev-parse --short HEAD)
VERSION = $(COMMIT)$(DIRTY)

# Override VERSION with the Git tag if the current HEAD has a tag pointing to
# it AND the worktree isn't dirty.
ifneq ($(GIT_TAG),)
	ifeq ($(DIRTY),)
		VERSION = $(GIT_TAG)
	endif
endif

ifneq ($(shell uname -s), Darwin)
	LINKFLAGS = -extldflags -static -w -s
endif

# Define target platforms, image builder and the fully qualified image name.
TARGET_PLATFORMS ?= linux/amd64,linux/arm64,linux/s390x
RUNNER := docker
IMAGE_BUILDER := $(RUNNER) buildx

REPO := rancher
ifeq ($(TAG),)
	TAG = $(VERSION)
	ifneq ($(DIRTY),)
		TAG = dev
	endif
endif

IMAGE = $(REPO)/security-scan:$(TAG)
TOOLS_IMAGE = security-scan-tools

GO := go

.DEFAULT_GOAL := ci
ci: build test validate e2e
release: ci

test:
	@echo "Running tests"
	go test -race -cover ./...

build:
	CGO_ENABLED=0 $(GO) build -ldflags "-X main.VERSION=$(VERSION) $(LINKFLAGS)" -o bin/kb-summarizer cmd/kb-summarizer/main.go
	./bin/kb-summarizer --version
	md5sum bin/kb-summarizer

.PHONY: package
package: buildx-machine ## build container image to current platform
	$(IMAGE_BUILDER) build -f package/Dockerfile -t "$(IMAGE)" --load .
	@echo "Built $(IMAGE)"

e2e: package
	@KUBE_VERSION=$(KUBE_VERSION) ./scripts/e2e

validate: tools
	@RUNNER=$(RUNNER) TOOLS_IMAGE=$(TOOLS_IMAGE) \
	./scripts/validate

tools:
	$(IMAGE_BUILDER) build -f Dockerfile.tools -t $(TOOLS_IMAGE) \
		--build-arg KIND_VERSION=$(KIND_VERSION) \
		--build-arg KUBERNETES_VERSION=$(KUBERNETES_VERSION) \
		--build-arg KUBE_BENCH_VERSION=$(KUBE_BENCH_VERSION) \
		--load .

buildx-machine:
	@docker buildx ls | grep rancher || \
		docker buildx create --name=rancher --platform=$(TARGET_PLATFORMS) --use
