TOOLS_BIN := $(shell mkdir -p build/tools && realpath build/tools)

GOIMPORTS = $(TOOLS_BIN)/goimports
$(GOIMPORTS): ## Download goimports if not yet downloaded.
	$(call go-install-tool,$(GOIMPORTS),golang.org/x/tools/cmd/goimports@latest)
	
GOLINT = $(TOOLS_BIN)/golint
$(GOLINT): ## Download golint locally if not yet downloaded.
	$(call go-install-tool,$(GOLINT),golang.org/x/lint/golint@latest)

KUBE_BENCH = $(TOOLS_BIN)/kube-bench
$(KUBE_BENCH): ## Download kube-bench locally if not yet downloaded.
	$(call go-install-tool,$(KUBE_BENCH),github.com/aquasecurity/kube-bench@$(KUBE_BENCH_VERSION))

KIND = $(TOOLS_BIN)/kind
$(KIND): ## Download kind locally if not yet downloaded.
	$(call go-install-tool,$(KIND),sigs.k8s.io/kind@v$(KIND_VERSION))

yamllint:
	@yamllint --version >/dev/null 2>&1 || (echo "ERROR: yamllint is required, install it with: pip install yamllint"; exit 1)

# go-install-tool will 'go install' any package $2 and install it as $1.
define go-install-tool
@[ -f $(1) ] || { \
set -e ;\
echo "Downloading $(2)" ;\
GOBIN=$(TOOLS_BIN) go install $(2) ;\
}
endef
