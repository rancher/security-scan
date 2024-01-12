# Define VERSION, which is used for image tags or to bake it into the
# compiled binary to enable the printing of the application version, 
# via the --version flag.
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

# Statically link the binary, unless when building in Darwin.
ifneq ($(shell uname -s), Darwin)
	LINKFLAGS = -extldflags -static -w -s
endif

RUNNER := docker
IMAGE_BUILDER := $(RUNNER) buildx
MACHINE := rancher

ifeq ($(TAG),)
	TAG = $(VERSION)
	ifneq ($(DIRTY),)
		TAG = dev
	endif
endif

GO := go

# Define the target platforms that can be used across the ecosystem.
# Note that what would actually be used for a given project will be
# defined in TARGET_PLATFORMS, and must be a subset of the below:
DEFAULT_PLATFORMS := linux/amd64,linux/arm64,linux/x390s,linux/riscv64

.PHONY: help
help: ## display Makefile's help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

buildx-machine: ## create rancher dockerbuildx machine targeting platform defined by DEFAULT_PLATFORMS.
	@docker buildx ls | grep $(MACHINE) || \
		docker buildx create --name=$(MACHINE) --platform=$(DEFAULT_PLATFORMS)
