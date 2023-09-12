FROM registry.suse.com/bci/bci-base:15.5

ARG kube_bench_version=0.6.12
ARG sonobuoy_version=0.56.16
ARG kubectl_version=1.28.0
ARG ARCH

RUN zypper --non-interactive update \
    && zypper --non-interactive install \
    systemd \
    curl \
    jq \
    tar \
    awk \
    gzip
RUN curl -Lo ./kubectl "https://storage.googleapis.com/kubernetes-release/release/v${kubectl_version}/bin/linux/${ARCH}/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/
RUN curl -sLf "https://github.com/vmware-tanzu/sonobuoy/releases/download/v${sonobuoy_version}/sonobuoy_${sonobuoy_version}_linux_${ARCH}.tar.gz" | tar -xvzf - -C /usr/bin sonobuoy
RUN curl -sLf "https://github.com/aquasecurity/kube-bench/releases/download/v${kube_bench_version}/kube-bench_${kube_bench_version}_linux_${ARCH}.tar.gz" | tar -xvzf - -C /usr/bin

# Copy the files within /cfg straight from the immutable GitHub source to /etc/kube-bench/cfg/.
RUN mkdir -p /etc/kube-bench/ && \
    curl -sLf "https://github.com/aquasecurity/kube-bench/archive/refs/tags/v${kube_bench_version}.tar.gz" | \
    tar xvz -C /etc/kube-bench/ --strip-components=1 "kube-bench-${kube_bench_version}/cfg"

COPY package/cfg/ /etc/kube-bench/cfg/
COPY package/run.sh \
    package/run_sonobuoy_plugin.sh \
    bin/kb-summarizer \
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
