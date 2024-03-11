# Platform specific images which must support all target architectures.
FROM registry.suse.com/bci/bci-micro:15.5 AS final
FROM registry.suse.com/bci/golang:1.22 AS golang

# Builder and xx only need to support the host architecture.
FROM --platform=$BUILDPLATFORM rancher/mirrored-tonistiigi-xx:1.3.0 as xx
FROM --platform=$BUILDPLATFORM registry.suse.com/bci/golang:1.22 AS builder

# Bring xx supporting tools to the builder layer, but as it is at / it
# won't be copied to the final image.
COPY --from=xx / /

# From this point onwards, although everything will be executed at the
# host architecture, it will fork and run separately for each target
# arch/platform.
ARG TARGETPLATFORM TARGETARCH
RUN mkdir -p /run/lock

# Set the final image base contents.
COPY --from=final / /chroot/

# The final image does not have zypper, so we amend the host zypper to
# look for the target architecture instead, so we can avoid cross-emulation.
RUN echo "[main]" > /etc/zypp/zypp.conf && \
    echo -n "arch = " >> /etc/zypp/zypp.conf && \
    xx-info march >> /etc/zypp/zypp.conf

# Zypper uses the architecture defined on the files within /etc/products.d/
# when fetching packages. Note that we are overriding host-based products.d
# files, with the same files from golang for the target architecture.
#
# On an amd64 host and arm64 target, this will ensure the files used are based
# on the arm64 version of /etc/products.d/.
COPY --from=golang /etc/products.d/ /etc/products.d/
# The zypper operations below will use an installroot. This copies the repository
# information (based on target arch) to chroot, so that the zypper operation works.
COPY --from=golang /etc/zypp/ /chroot/etc/zypp/

# OS binaries to run kube-bench audit commands.
# Before removing dependencies here, ensure they are not needed by cis-operator,
# security-scan or any of the existing kube-bench tests.
RUN zypper --non-interactive refresh && \
    zypper --installroot /chroot -n in --no-recommends findutils tar jq gawk diffutils procps systemd gzip curl && \
    zypper --installroot /chroot clean -a && \
    rm -rf /chroot/var/cache/zypp/* /chroot/var/log/zypp/* /chroot/etc/zypp/

# Safety net to ensure we did not mess up on the zypper operations above,
# and that the binaries are valid for the target architecture.
RUN xx-verify /chroot/usr/bin/curl && \
    xx-verify /chroot/usr/bin/diff && \
    xx-verify /chroot/usr/bin/tar && \
    xx-verify /chroot/usr/bin/jq && \
    xx-verify /chroot/usr/bin/gzip

# Define build arguments.
ARG KUBE_BENCH_VERSION KUBE_BENCH_SUM_arm64 KUBE_BENCH_SUM_amd64 \
    SONOBUOY_VERSION SONOBUOY_SUM_arm64 SONOBUOY_SUM_amd64 \
    KUBECTL_VERSION KUBECTL_SUM_arm64 KUBECTL_SUM_amd64

# Stage Sonobuoy into builder.
ENV SONOBUOY_SUM="SONOBUOY_SUM_${TARGETARCH}"
RUN curl --output /tmp/sonobuoy.tar.gz -sLf "https://github.com/vmware-tanzu/sonobuoy/releases/download/v${SONOBUOY_VERSION}/sonobuoy_${SONOBUOY_VERSION}_linux_${TARGETARCH}.tar.gz" && \
    echo "${!SONOBUOY_SUM}  /tmp/sonobuoy.tar.gz" | sha256sum -c - && \
    tar -xvzf /tmp/sonobuoy.tar.gz -C /chroot/usr/bin sonobuoy

# Stage kubectl into builder.
ADD --chown=root:root --chmod=0755 \
    "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
    /chroot/usr/local/bin/kubectl

ENV KUBECTL_SUM="KUBECTL_SUM_${TARGETARCH}"
RUN echo "${!KUBECTL_SUM}  /chroot/usr/local/bin/kubectl" | sha256sum -c -

# Stage kube-bench into builder.
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

# Wraps the go compiler so that it automatically takes into account TARGETPLATFORM.
RUN xx-go --wrap 

# By setting the version as an argument, we can avoid running the version logic 
# a second time (inside the Docker build process). Therefore, removing the need
# to access the .git dir.
ARG VERSION
RUN VERSION=${VERSION} TARGET_BIN=/chroot/usr/bin/kb-summarizer make build

# Ensures that the binary that was built is valid for the target platform.
RUN xx-verify --static /chroot/usr/bin/kb-summarizer

# Override kube-bench cfg files without duplicating them on the final image.
COPY package/cfg/ /chroot/etc/kube-bench/cfg/


# By using scratch we avoid duplicating files on the final image,
# as otherwise the COPY below would override the differences between
# /chroot and "final", increasing the image layer by ~10MB. 
FROM scratch

COPY --from=builder /chroot/ /
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
