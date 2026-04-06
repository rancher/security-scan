TOOLS_BIN := $(shell mkdir -p build/tools && realpath build/tools)

GOIMPORTS = $(TOOLS_BIN)/goimports
$(GOIMPORTS): ## Download goimports if not yet downloaded.
	$(call go-install-tool,$(GOIMPORTS),golang.org/x/tools/cmd/goimports@latest)

GOLANGCI := $(TOOLS_BIN)/golangci-lint-$(GOLANGCI_VERSION)
GOLANGCI_VERSION_TRIMMED := $(GOLANGCI_VERSION:v%=%)
$(GOLANGCI):
		tmp=$$(mktemp -d); \
	url="https://github.com/golangci/golangci-lint/releases/download/$(GOLANGCI_VERSION)/golangci-lint-$(GOLANGCI_VERSION_TRIMMED)-linux-amd64.tar.gz"; \
	curl -sSfL -o $$tmp/pkg.tgz "$$url"; \
	echo "$(GOLANGCI_SUM_$(OS_ARCH))  $$tmp/pkg.tgz" | shasum -a 256 -c -; \
	tar -xf $$tmp/pkg.tgz -C $$tmp; \
	mv $$tmp/golangci-lint-$(GOLANGCI_VERSION_TRIMMED)-linux-amd64/golangci-lint $(GOLANGCI); \
	chmod u+x $(GOLANGCI); \
	rm -rf $$tmp

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
