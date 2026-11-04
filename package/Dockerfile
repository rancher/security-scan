# Platform specific images which must support all target architectures.
# bci-nano is the base of the final image, as recommended by RFD 0070. It has
# no shell, package manager or OS tools, so whatever the image needs on top of
# it is installed explicitly further down.
FROM registry.suse.com/bci/bci-nano:15.7 AS nano
# Only used as the source of the zypper repositories and product files for the
# target architecture.
FROM registry.suse.com/bci/bci-base:15.7 AS base

# xx only needs to support the host architecture.
FROM --platform=$BUILDPLATFORM rancher/mirrored-tonistiigi-xx:1.6.1 AS xx

# Assembles the final root filesystem for the target architecture in /chroot.
# It runs on the host architecture and uses zypper from BCI base, as neither
# bci-nano nor the AppCo Go image have a package manager.
FROM --platform=$BUILDPLATFORM registry.suse.com/bci/bci-base:15.7 AS rootfs

# file is needed by xx-verify.
RUN zypper --non-interactive install --no-recommends file

# Bring xx supporting tools to the rootfs layer, but as it is at / it
# won't be copied to the final image.
COPY --from=xx / /

# From this point onwards, although everything will be executed at the
# host architecture, it will fork and run separately for each target
# arch/platform.
ARG TARGETPLATFORM TARGETARCH
RUN mkdir -p /run/lock

# Set the final image base contents.
COPY --from=nano / /chroot/

# The final image does not have zypper, so we amend the host zypper to
# look for the target architecture instead, so we can avoid cross-emulation.
RUN echo "[main]" > /etc/zypp/zypp.conf && \
    echo -n "arch = " >> /etc/zypp/zypp.conf && \
    xx-info march >> /etc/zypp/zypp.conf

# Zypper uses the architecture defined on the files within /etc/products.d/
# when fetching packages. Note that we are overriding host-based products.d
# files, with the same files from bci-base for the target architecture.
#
# On an amd64 host and arm64 target, this will ensure the files used are based
# on the arm64 version of /etc/products.d/.
COPY --from=base /etc/products.d/ /etc/products.d/
# The zypper operations below will use an installroot. This copies the repository
# information (based on target arch) to chroot, so that the zypper operation works.
COPY --from=base /etc/zypp/ /chroot/etc/zypp/

# OS packages to run the kube-bench audit commands, the helper scripts and the
# packaging of the Sonobuoy results. bci-nano has none of them, so the basic
# ones that other BCI images provide implicitly are listed too. Everything else
# that ends up installed is a dependency of these packages.
# Before removing one, ensure it is not needed by security-scan or any of the
# existing kube-bench tests:
# - bash, coreutils, grep, sed: the shell, and the file and text utilities
#   (stat, cat, tail, chmod...) that the audits and package/ scripts call.
# - findutils: find and xargs.
# - gawk: awk, used by the helper scripts that check the kubelet CA file.
# - procps: ps, to inspect the processes of the node.
# - systemd: systemctl and journalctl, to check the services of the node.
# - jq: processing of JSON output.
# - curl: audits that call API endpoints.
# - diffutils: diff.
# - tar and gzip: packaging and unpacking the Sonobuoy results (tar -z).
RUN zypper --non-interactive --releasever=15.6 refresh && \
    zypper --installroot /chroot -n in --no-recommends bash coreutils grep sed findutils gawk procps systemd jq curl diffutils tar gzip && \
    zypper --installroot /chroot clean -a && \
    rm -rf /chroot/var/cache/zypp/* /chroot/var/log/zypp/* /chroot/etc/zypp/

# Safety net to ensure we did not mess up on the zypper operations above,
# and that the binaries are valid for the target architecture.
RUN xx-verify /chroot/usr/bin/bash && \
    xx-verify /chroot/usr/bin/curl && \
    xx-verify /chroot/usr/bin/diff && \
    xx-verify /chroot/usr/bin/tar && \
    xx-verify /chroot/usr/bin/jq && \
    xx-verify /chroot/usr/bin/gzip

# Define build arguments.
ARG KUBE_BENCH_VERSION KUBE_BENCH_SUM_arm64 KUBE_BENCH_SUM_amd64 \
    KUBECTL_VERSION KUBECTL_SUM_arm64 KUBECTL_SUM_amd64

# Stage kubectl into builder.
ADD --chown=root:root --chmod=0755 \
    "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
    /chroot/usr/local/bin/kubectl

ENV KUBECTL_SUM="KUBECTL_SUM_${TARGETARCH}"
RUN echo "${!KUBECTL_SUM}  /chroot/usr/local/bin/kubectl" | sha256sum -c -

# Stage kube-bench into builder.
ENV KUBE_BENCH_SUM="KUBE_BENCH_SUM_${TARGETARCH}"
RUN curl --output /tmp/kubebench.tar.gz -sLf "https://github.com/aquasecurity/kube-bench/releases/download/${KUBE_BENCH_VERSION}/kube-bench_${KUBE_BENCH_VERSION#v}_linux_${TARGETARCH}.tar.gz" && \
    echo "${!KUBE_BENCH_SUM}  /tmp/kubebench.tar.gz" | sha256sum -c - && \
    tar -xvzf /tmp/kubebench.tar.gz -C /chroot/usr/bin

# Copy the files within /cfg straight from the immutable GitHub source to /etc/kube-bench/cfg/ into the image
RUN mkdir -p /chroot/etc/kube-bench/ && \
    curl --output - -sLf "https://github.com/aquasecurity/kube-bench/archive/refs/tags/${KUBE_BENCH_VERSION}.tar.gz" | \
    tar xvz -C /chroot/etc/kube-bench/ --strip-components=1 "kube-bench-${KUBE_BENCH_VERSION#v}/cfg"

# Override kube-bench cfg files without duplicating them on the final image.
COPY package/cfg/ /chroot/etc/kube-bench/cfg/

# The AppCo Go image has no package manager, so the extra tools needed by
# the build (git, make) and by xx (file, flock, sed, grep) are installed
# from BCI base. Its SLE version must match the one AppCo Go is based on.
FROM --platform=$BUILDPLATFORM registry.suse.com/bci/bci-base:15.7 AS tools
RUN zypper --non-interactive refresh && \
    zypper --non-interactive --installroot /tools install --no-recommends \
        git-core make file sed grep util-linux

# Builds with the Go compiler from the AppCo Go image, as recommended by
# RFD 0070. Pinned to MAJOR.MINOR.PATCH, matching go.mod, so the toolchain
# is deterministic and bumped by Renovate.
FROM --platform=$BUILDPLATFORM registry.suse.com/rancher/appco-go:1.27.2 AS builder

COPY --from=tools /tools /
# Bring xx supporting tools to the builder layer, but as it is at / it
# won't be copied to the final image.
COPY --from=xx / /

ARG SONOBUOY_VERSION
# The upstream project hasn't been released in almost one year, which
# caused it to accumulate several stdlib Golang vulnerabilities.
RUN git clone --depth=1 https://github.com/vmware-tanzu/sonobuoy --branch "${SONOBUOY_VERSION}" --single-branch /go/src/github.com/vmware-tanzu/sonobuoy

ARG TARGETPLATFORM
RUN mkdir -p /run/lock

RUN --mount=type=cache,target=/go/pkg/mod \
    cd /go/src/github.com/vmware-tanzu/sonobuoy && \
    xx-go build -o /out/sonobuoy \
        -ldflags "-s -w -X github.com/vmware-tanzu/sonobuoy/pkg/buildinfo.Version=${SONOBUOY_VERSION}-rancher -X github.com/vmware-tanzu/sonobuoy/pkg/buildinfo.GitSHA=$(git rev-parse HEAD)"
RUN xx-verify /out/sonobuoy

WORKDIR /src
COPY go.sum \
     go.mod \
     Makefile \
     /src
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY pkg /src/pkg
COPY hack /src/hack
COPY cmd /src/cmd

# Wraps the go compiler so that it automatically takes into account TARGETPLATFORM.
RUN xx-go --wrap 

# By setting the version as an argument, we can avoid running the version logic 
# a second time (inside the Docker build process). Therefore, removing the need
# to access the .git dir.
ARG VERSION
RUN --mount=type=cache,target=/go/pkg/mod \
    VERSION=${VERSION} TARGET_BIN=/out/kb-summarizer make build

# Ensures that the binary that was built is valid for the target platform.
RUN xx-verify --static /out/kb-summarizer


# By using scratch we avoid duplicating files on the final image,
# as otherwise the COPY below would override the differences between
# /chroot and the nano base, increasing the image layer by ~10MB. 
FROM scratch

COPY --from=rootfs /chroot/ /
COPY --from=builder /out/ /usr/bin/
COPY package/run.sh \
    package/run_sonobuoy_plugin.sh \
    package/helper_scripts/check_files_permissions.sh \
    package/helper_scripts/check_files_owner_in_dir.sh \
    package/helper_scripts/check_encryption_provider_config.sh \
    package/helper_scripts/check_for_network_policies.sh \
    package/helper_scripts/check_for_default_sa.sh \
    package/helper_scripts/check_for_default_ns.sh \
    package/helper_scripts/check_for_rke2_network_policies.sh \
    package/helper_scripts/check_for_rke2_cni_net_policy_support.sh \
    package/helper_scripts/check_cafile_permissions.sh \
    package/helper_scripts/check_cafile_ownership.sh \
    /usr/bin/

CMD ["run.sh"]
