# Platform specific images which must support all target architectures.
FROM registry.suse.com/bci/bci-micro:15.7 AS final
FROM registry.suse.com/bci/golang:1.27 AS golang

# Builder and xx only need to support the host architecture.
FROM --platform=$BUILDPLATFORM rancher/mirrored-tonistiigi-xx:1.6.1 AS xx
FROM --platform=$BUILDPLATFORM registry.suse.com/bci/golang:1.27 AS builder

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
# Before removing dependencies here, ensure they are not needed by
# the compliance-operator, security-scan or any of the existing kube-bench
# tests.
#
# kube-bench, sonobuoy and kubectl come from the cowboy-builder RPM packages,
# which are rebuilt with the latest Go patch version and have fixes for CVEs in their dependencies.
ARG KUBECTL_PACKAGE=kubectl-1.37
RUN rpm --import https://raw.githubusercontent.com/rancher/rancher/refs/heads/main/rancher-rpm-pkgs.key && \
    rpm --root /chroot --import https://raw.githubusercontent.com/rancher/rancher/refs/heads/main/rancher-rpm-pkgs.key && \
    zypper ar -f https://rpm.rancher.io/pkgs/prime pkgs && \
    zypper --non-interactive --releasever=15.6 refresh && \
    zypper --installroot /chroot -n in --no-recommends findutils tar jq gawk diffutils procps systemd gzip curl && \
    zypper --installroot /chroot -n in --no-recommends -r pkgs kube-bench sonobuoy ${KUBECTL_PACKAGE} && \
    install -D -o root -g root -m 0755 /chroot/usr/bin/${KUBECTL_PACKAGE} /chroot/usr/local/bin/kubectl && \
    rm -f /chroot/usr/bin/${KUBECTL_PACKAGE} && \
    zypper --installroot /chroot clean -a && \
    rm -rf /chroot/var/cache/zypp/* /chroot/var/log/zypp/* /chroot/etc/zypp/

# Safety net to ensure we did not mess up on the zypper operations above,
# and that the binaries are valid for the target architecture.
RUN xx-verify /chroot/usr/bin/curl && \
    xx-verify /chroot/usr/bin/diff && \
    xx-verify /chroot/usr/bin/tar && \
    xx-verify /chroot/usr/bin/jq && \
    xx-verify /chroot/usr/bin/gzip && \
    xx-verify /chroot/usr/bin/kube-bench && \
    xx-verify /chroot/usr/bin/sonobuoy && \
    xx-verify /chroot/usr/local/bin/kubectl

# Define build arguments.
ARG KUBE_BENCH_VERSION

# Copy the files within /cfg straight from the immutable GitHub source to /etc/kube-bench/cfg/ into micro
RUN mkdir -p /chroot/etc/kube-bench/ && \
    curl --output - -sLf "https://github.com/aquasecurity/kube-bench/archive/refs/tags/${KUBE_BENCH_VERSION}.tar.gz" | \
    tar xvz -C /chroot/etc/kube-bench/ --strip-components=1 "kube-bench-${KUBE_BENCH_VERSION#v}/cfg"

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
    package/helper_scripts/check_for_rke2_network_policies.sh \
    package/helper_scripts/check_for_rke2_cni_net_policy_support.sh \
    package/helper_scripts/check_cafile_permissions.sh \
    package/helper_scripts/check_cafile_ownership.sh \
    /usr/bin/

CMD ["run.sh"]
