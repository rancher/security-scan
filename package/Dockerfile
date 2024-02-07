# Final micro image
FROM registry.suse.com/bci/bci-micro:15.5 AS micro

# Image that provides cross compilation tooling.
FROM --platform=$BUILDPLATFORM rancher/mirrored-tonistiigi-xx:1.3.0 as xx

# Temporary build stage
FROM --platform=$BUILDPLATFORM registry.suse.com/bci/golang:1.21 AS builder

# Define build arguments
ARG KUBE_BENCH_VERSION KUBE_BENCH_SUM_arm64 KUBE_BENCH_SUM_amd64 \
    SONOBUOY_VERSION SONOBUOY_SUM_arm64 SONOBUOY_SUM_amd64 \
    KUBECTL_VERSION KUBECTL_SUM_arm64 KUBECTL_SUM_amd64

ARG TARGETARCH

# Install system packages using builder image that has zypper 
COPY --from=micro / /chroot/

# OS binaries to run kube-bench audit commands.
# Before removing dependencies here, ensure they are not needed by cis-operator,
# security-scan or any of the existing kube-bench tests.
RUN zypper refresh && \
    zypper --installroot /chroot -n in --no-recommends findutils tar jq gawk diffutils procps systemd gzip curl && \
    zypper --installroot /chroot clean -a && \
    rm -rf /chroot/var/cache/zypp/* /chroot/var/log/zypp/*


# Stage Sonobuoy into builder
ENV SONOBUOY_SUM="SONOBUOY_SUM_${TARGETARCH}"
RUN curl --output /tmp/sonobuoy.tar.gz -sLf "https://github.com/vmware-tanzu/sonobuoy/releases/download/v${SONOBUOY_VERSION}/sonobuoy_${SONOBUOY_VERSION}_linux_${TARGETARCH}.tar.gz" && \
    echo "${!SONOBUOY_SUM}  /tmp/sonobuoy.tar.gz" | sha256sum -c - && \
    tar -xvzf /tmp/sonobuoy.tar.gz -C /chroot/usr/bin sonobuoy

# Stage kubectl into builder
ADD --chown=root:root --chmod=0755 \
    "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
    /chroot/usr/local/bin/kubectl

ENV KUBECTL_SUM="KUBECTL_SUM_${TARGETARCH}"
RUN echo "${!KUBECTL_SUM}  /chroot/usr/local/bin/kubectl" | sha256sum -c -

# Stage kube-bench into builder
ENV KUBE_BENCH_SUM="KUBE_BENCH_SUM_${TARGETARCH}"
RUN curl --output /tmp/kubebench.tar.gz -sLf "https://github.com/aquasecurity/kube-bench/releases/download/v${KUBE_BENCH_VERSION}/kube-bench_${KUBE_BENCH_VERSION}_linux_${TARGETARCH}.tar.gz" && \
    echo "${!KUBE_BENCH_SUM}  /tmp/kubebench.tar.gz" | sha256sum -c - && \
    tar -xvzf /tmp/kubebench.tar.gz -C /chroot/usr/bin

# Copy the files within /cfg straight from the immutable GitHub source to /etc/kube-bench/cfg/ into micro
RUN mkdir -p /chroot/etc/kube-bench/ && \
    curl -sLf "https://github.com/aquasecurity/kube-bench/archive/refs/tags/v${KUBE_BENCH_VERSION}.tar.gz" | \
    tar xvz -C /chroot/etc/kube-bench/ --strip-components=1 "kube-bench-${KUBE_BENCH_VERSION}/cfg"

WORKDIR /src
COPY go.sum \
     go.mod \
     Makefile \
     /src
RUN go mod download

COPY pkg /src/pkg
COPY hack /src/hack
COPY cmd /src/cmd

# By setting the version as an argument, we can avoid running the version logic 
# a second time (inside the Docker build process). Therefore, removing the need
# to access the .git dir.
ARG VERSION
RUN VERSION=${VERSION} TARGET_BIN=/chroot/usr/bin/kb-summarizer make build

# Ensures that the binary that was built was cross-compiled correctly
# and is valid on the target platform.
COPY --from=xx \
    /usr/bin/xx-verify \
    /usr/bin/xx-info \
    /usr/bin
RUN mkdir -p /run/lock
RUN xx-verify --static /chroot/usr/bin/kb-summarizer

# Main stage using bci-micro as the base image
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
