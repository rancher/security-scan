FROM registry.suse.com/bci/bci-base:15.4

ARG kube_bench_version=0.6.12
ARG sonobuoy_version=0.56.16
ARG kubectl_version=1.26.3

RUN zypper --non-interactive update \
    && zypper --non-interactive install \
    curl \
    jq \
    vim \
    systemd \
    tar \
    awk \
    gzip
RUN curl -sLf "https://storage.googleapis.com/kubernetes-release/release/v${kubectl_version}/bin/linux/amd64/kubectl" > "/usr/local/bin/kubectl-${kubectl_version}" \
    && ln -sv "/usr/local/bin/kubectl-${kubectl_version}" /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl*
RUN curl -sLf "https://github.com/vmware-tanzu/sonobuoy/releases/download/v${sonobuoy_version}/sonobuoy_${sonobuoy_version}_linux_amd64.tar.gz" | tar -xvzf - -C /usr/bin sonobuoy
RUN curl -sLf "https://github.com/aquasecurity/kube-bench/releases/download/v${kube_bench_version}/kube-bench_${kube_bench_version}_linux_amd64.tar.gz" | tar -xvzf - -C /usr/bin

# Copy the files within /cfg straight from the immutable GitHub source to /etc/kube-bench/cfg/.
RUN curl -sLf "https://github.com/aquasecurity/kube-bench/archive/refs/tags/v${kube_bench_version}.tar.gz" | \
    tar xvz -C . --strip-components=1 "kube-bench-${kube_bench_version}/cfg"

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
