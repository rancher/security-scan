FROM ubuntu:18.04

ARG kube_bench_tag=0.1.0
ARG sonobuoy_version=0.16.3

RUN apt-get update \
    && apt-get install -y \
        curl \
        jq \
        vim
RUN curl -sLf https://storage.googleapis.com/kubernetes-release/release/v1.13.5/bin/linux/amd64/kubectl > /usr/local/bin/kubectl-1.13 \
    && ln -sv /usr/local/bin/kubectl-1.13 /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl*
RUN curl -sLf https://github.com/vmware-tanzu/sonobuoy/releases/download/v${sonobuoy_version}/sonobuoy_${sonobuoy_version}_linux_amd64.tar.gz | tar -xvzf - -C /usr/bin sonobuoy
RUN curl -sLf https://github.com/aquasecurity/kube-bench/releases/download/v${kube_bench_tag}/kube-bench_${kube_bench_tag}_linux_amd64.tar.gz | tar -xvzf - -C /usr/bin

COPY package/cfg/ /cfg/
COPY package/etcdcfg/ /etcdcfg/
COPY package/run.sh \
     package/run_sonobuoy_plugin.sh \
     bin/kb-summarizer \
     package/helper_scripts/check_files_permissions.sh \
     package/helper_scripts/check_files_owner_in_dir.sh \
     package/helper_scripts/check_encryption_provider_config.sh \
     /usr/bin/

CMD ["run.sh"]
