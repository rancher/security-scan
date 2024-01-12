# Final micro image
FROM registry.suse.com/bci/bci-micro:15.5 AS micro

# Image that provides cross compilation tooling.
FROM --platform=$BUILDPLATFORM tonistiigi/xx:latest as xx

# Temporary build stage
FROM registry.suse.com/bci/golang:1.21 AS builder

# Define build arguments
ARG KUBE_BENCH_VERSION
ARG SONOBUOY_VERSION
ARG KUBECTL_VERSION

ARG TARGETARCH

# Install system packages using builder image that has zypper 
COPY --from=micro / /chroot/

# Install kubectl into micro
ADD --chown=root:root --chmod=0755 \
    "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
    /chroot/usr/local/bin/kubectl

## Install Sonobuoy into micro
RUN curl -sLf "https://github.com/vmware-tanzu/sonobuoy/releases/download/v${SONOBUOY_VERSION}/sonobuoy_${SONOBUOY_VERSION}_linux_${TARGETARCH}.tar.gz" | tar -xvzf - -C /chroot/usr/bin sonobuoy

## Install kube-bench into micro
RUN curl -sLf "https://github.com/aquasecurity/kube-bench/releases/download/v${KUBE_BENCH_VERSION}/kube-bench_${KUBE_BENCH_VERSION}_linux_${TARGETARCH}.tar.gz" | tar -xvzf - -C /chroot/usr/bin

## Copy the files within /cfg straight from the immutable GitHub source to /etc/kube-bench/cfg/ into micro
RUN mkdir -p /chroot/etc/kube-bench/ && \
    curl -sLf "https://github.com/aquasecurity/kube-bench/archive/refs/tags/v${KUBE_BENCH_VERSION}.tar.gz" | \
    tar xvz -C /chroot/etc/kube-bench/ --strip-components=1 "kube-bench-${KUBE_BENCH_VERSION}/cfg"

## OS binaries to run kube-bench audit commands
RUN zypper --installroot /chroot -n --gpg-auto-import-keys in --no-recommends findutils tar jq gawk diffutils procps systemd gzip curl  && \
    zypper --installroot /chroot clean -a && \
    rm -rf /chroot/var/cache/zypp/* /chroot/var/log/zypp/*

WORKDIR /src
COPY go.sum \
     go.mod \
     Makefile \
     /src
RUN go mod download

COPY .git /src/.git
COPY pkg /src/pkg
COPY hack /src/hack
COPY cmd /src/cmd

RUN TARGET_BIN=/chroot/usr/bin/kb-summarizer make build

# Ensures that the binary that was built was cross-compiled correctly
# and is valid on the target platform.
COPY --from=xx \
    /usr/bin/xx-verify \
    /usr/bin/xx-info \
    /usr/bin
RUN mkdir -p /run/lock
RUN xx-verify --static /chroot/usr/bin/kb-summarizer

# Main stage using bco-micro as the base image
FROM micro

# Copy binaries and configuration files from builder to micro
COPY --from=builder /chroot/ /

# Copy binaries and configuration files from the local repository to micro
COPY package/cfg/ /etc/kube-bench/cfg/
COPY package/run.sh \
    package/run_sonobuoy_plugin.sh \
    package/helper_scripts/check_files_permissions.sh \
    package/helper_scripts/check_files_owner_in_dir.sh \
    package/helper_scripts/check_encryption_provider_config.sh \
    package/helper_scripts/check_for_network_policies.sh \
    package/helper_scripts/check_for_default_sa.sh \
    package/helper_scripts/check_for_default_ns.sh \
    package/helper_scripts/check_for_k3s_etcd.sh \
    package/helper_scripts/check_for_rke2_network_policies.sh \
    package/helper_scripts/check_for_rke2_cni_net_policy_support.sh \
    package/helper_scripts/check_cafile_permissions.sh \
    package/helper_scripts/check_cafile_ownership.sh \
    /usr/bin/

CMD ["run.sh"]
