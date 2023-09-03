#!/bin/bash

VERSION="1.28.0"
POD_NETWORK_CIDR="10.244.0.0/16"
SERVICE_CIDR="10.96.0.0/12"
EMAIL="hansi@bihalu.de"
BUILD_START=$(date +%s)

################################################################################
# apk packages for airgap installation -> https://pkgs.alpinelinux.org/packages
readarray -t PACKAGES <<EOL_PACKAGES
# bash
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/readline-8.2.1-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/bash-5.2.15-r5.apk
# wireguard-tools-wg
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/wireguard-tools-wg-1.0.20210914-r3.apk
# jq
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/oniguruma-6.9.8-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/jq-1.6-r3.apk
# minio-client
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/minio-client-0.20230323.200304-r3.apk
# iptables
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libmnl-1.0.5-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libnftnl-1.2.5-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/iptables-1.8.9-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/iptables-openrc-1.8.9-r2.apk
# iproute2
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libbz2-1.0.8-r5.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/musl-fts-1.2.7-r5.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libelf-0.189-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/iproute2-minimal-6.3.0-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/ifupdown-ng-iproute2-0.12.1-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/iproute2-tc-6.3.0-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/iproute2-ss-6.3.0-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/iproute2-6.3.0-r0.apk
# socat
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/socat-1.7.4.4-r1.apk
# ethtool
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/ethtool-6.2-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/ifupdown-ng-ethtool-0.12.1-r2.apk
# conntrack-tools
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libnfnetlink-1.0.2-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libnetfilter_conntrack-1.0.9-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libnetfilter_cthelper-1.0.1-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libnetfilter_cttimeout-1.0.1-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libnetfilter_queue-1.0.5-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/conntrack-tools-1.4.7-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/conntrack-tools-openrc-1.4.7-r1.apk
# containerd
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libseccomp-2.5.4-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/runc-1.1.7-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/containerd-1.7.2-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/containerd-openrc-1.7.2-r1.apk
# containerd-ctr
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/containerd-ctr-1.7.2-r1.apk
# k9s
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/k9s-0.27.4-r1.apk
# cni-plugins
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/cni-plugins-1.3.0-r1.apk
# podman
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libintl-0.21.1-r7.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libmount-2.38.1-r8.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/pcre2-10.42-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/glib-2.76.4-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/conmon-2.1.7-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libseccomp-2.5.4-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/yajl-2.1.0-r6.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/crun-1.8.4-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/ip6tables-1.8.9-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/ip6tables-openrc-1.8.9-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/libslirp-4.7.0-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/slirp4netns-1.2.0-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/linux-pam-1.5.2-r10.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/shadow-libs-4.13-r4.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/shadow-subids-4.13-r4.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/containers-common-0.52.0-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libgcc-12.2.1_git20220924-r10.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/netavark-1.6.0-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/aardvark-dns-1.6.0-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/catatonit-0.1.7-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libgpg-error-1.47-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libassuan-2.5.6-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/pinentry-1.2.1-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libgcrypt-1.10.2-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/gnupg-gpgconf-2.4.3-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libksba-1.6.4-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/gdbm-1.23-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libsasl-2.1.28-r4.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libldap-2.6.5-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/npth-1.6-r4.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/gnupg-dirmngr-2.4.3-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/sqlite-libs-3.41.2-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/gnupg-keyboxd-2.4.3-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/gpg-2.4.3-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/gpg-agent-2.4.3-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/gpgsm-2.4.3-r0.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/gpgme-1.20.0-r1.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/podman-4.5.1-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/podman-openrc-4.5.1-r2.apk
# helm
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/helm-3.11.3-r1.apk
# gcompat
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/musl-obstack-1.2.3-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/libucontext-1.2-r2.apk
https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/gcompat-1.1.0-r1.apk
EOL_PACKAGES

SKIP_PACKAGES=0
DOWNLOAD=true
INSTALL=true
RETRY=3

for PACKAGE in "${PACKAGES[@]}" ; do
  # don't process commented out packages
  [[ ${PACKAGE:0:1} = \# ]] && continue

  # skip packages
  [[ ${SKIP_PACKAGES} -gt 0 ]] && ((SKIP_PACKAGES--)) && continue

  # parse package url
  PACKAGE_PATH=$(echo ${PACKAGE} | cut -d/ -f4-)
  PACKAGE_NAME=$(echo ${PACKAGE_PATH} | cut -d/ -f5-)
  MIRROR=${PACKAGE%$PACKAGE_PATH}
  PACKAGE_DIR=${PACKAGE_PATH%$PACKAGE_NAME}

  # create package dir
  mkdir -p ${PACKAGE_DIR}

  # download package
  if [[ ${DOWNLOAD} = true ]] ; then
    # skip download if already available
    [[ -f ${PACKAGE_PATH} ]] && continue

    # retry attempts
    for N in $(seq 2 $RETRY) ; do
      echo "Download package ${PACKAGE}..." 
      wget ${PACKAGE} -O ${PACKAGE_PATH} 
      RC=$?
      if [[ $RC == 0 ]] ; then 
        break
      else
        echo "Try #$N in 10 seconds..."
        sleep 10
      fi 
    done

    [[ $RC != 0 ]] && exit 1
  fi

  # install package
  if [[ ${INSTALL} = true ]] ; then
    apk add --repositories-file=/dev/null --allow-untrusted --no-network --no-cache ${PACKAGE_PATH}

    # exit on install error
    [[ $? != 0 ]] && exit 1
  fi
done

################################################################################
# container images for airgap installation
readarray -t IMAGES <<EOL_IMAGES
################################################################################
# kube-prometheus-stack v0.66.0 -> https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack/48.3.1
quay.io/prometheus/node-exporter:v1.6.0
quay.io/kiwigrid/k8s-sidecar:1.24.6
docker.io/grafana/grafana:10.0.3
registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.9.2
quay.io/prometheus-operator/prometheus-operator:v0.66.0
quay.io/prometheus/alertmanager:v0.25.0
quay.io/prometheus/prometheus:v2.45.0
################################################################################
# openebs 3.8.0 -> https://artifacthub.io/packages/helm/openebs/openebs/3.8.0
docker.io/openebs/node-disk-exporter:2.1.0
docker.io/openebs/node-disk-manager:2.1.0
docker.io/openebs/node-disk-operator:2.1.0
docker.io/openebs/provisioner-localpv:3.4.0
docker.io/openebs/linux-utils:3.4.0
################################################################################
# cert-manager 1.12.3 -> https://artifacthub.io/packages/helm/cert-manager/cert-manager/1.12.3
quay.io/jetstack/cert-manager-cainjector:v1.12.3
quay.io/jetstack/cert-manager-controller:v1.12.3
quay.io/jetstack/cert-manager-webhook:v1.12.3
quay.io/jetstack/cert-manager-acmesolver:v1.12.3
quay.io/jetstack/cert-manager-ctl:v1.12.3
quay.io/jetstack/cert-manager-webhook:v1.12.3
################################################################################
# ingress-nginx v1.8.1 -> https://github.com/kubernetes/ingress-nginx/blob/helm-chart-4.7.1/charts/ingress-nginx/values.yaml#L26
registry.k8s.io/ingress-nginx/controller:v1.8.1
registry.k8s.io/ingress-nginx/opentelemetry:v20230527
registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20230407
registry.k8s.io/defaultbackend-amd64:1.5
################################################################################
# calico v3.26.1 -> https://artifacthub.io/packages/helm/projectcalico/tigera-operator/3.26.1
quay.io/tigera/operator:v1.30.4
docker.io/calico/apiserver:v3.26.1
docker.io/calico/cni:v3.26.1
docker.io/calico/csi:v3.26.1
docker.io/calico/kube-controllers:v3.26.1
docker.io/calico/node-driver-registrar:v3.26.1
docker.io/calico/node:v3.26.1
docker.io/calico/pod2daemon-flexvol:v3.26.1
docker.io/calico/typha:v3.26.1
################################################################################
# k8s 1.28.0 -> https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.28.md#container-images-1
registry.k8s.io/kube-apiserver:v1.28.0
registry.k8s.io/kube-controller-manager:v1.28.0
registry.k8s.io/kube-proxy:v1.28.0
registry.k8s.io/kube-scheduler:v1.28.0
registry.k8s.io/coredns/coredns:v1.10.1
registry.k8s.io/etcd:3.5.9-0
registry.k8s.io/pause:3.9
EOL_IMAGES

SKIP_IMAGES=0
PULL=true
CONTAINER_IMAGES=""

for IMAGE in "${IMAGES[@]}" ; do
  # don't process commented out images
  [[ ${IMAGE:0:1} = \# ]] && continue

  # skip images
  [[ ${SKIP_IMAGES} -gt 0 ]] && ((SKIP_IMAGES--)) && continue

  # pull image
  if [[ ${PULL} = true ]] ; then
    podman pull ${IMAGE}

    # exit on install error
    [[ $? != 0 ]] && exit 1
  fi

  CONTAINER_IMAGES+=" "
  CONTAINER_IMAGES+=${IMAGE}
done

SAVE=true

if [[ ${SAVE} = true ]] ; then
  # save images as tar file
  mkdir -p container

  # cleanup container images tar file
  [[ -f container/images.tar ]] && rm -f container/images.tar

  # save all images in container images tar file
  podman save --multi-image-archive --output container/images.tar ${CONTAINER_IMAGES}
fi

################################################################################
# helm charts -> chart_url chart_repo chart_name chart_version
readarray -t HELM_CHARTS <<EOL_HELM_CHARTS
https://prometheus-community.github.io/helm-charts prometheus-community kube-prometheus-stack 48.3.1
https://openebs.github.io/charts openebs openebs 3.8.0
https://charts.jetstack.io jetstack cert-manager v1.12.3
https://kubernetes.github.io/ingress-nginx ingress-nginx ingress-nginx 4.7.1
https://projectcalico.docs.tigera.io/charts projectcalico tigera-operator v3.26.1
EOL_HELM_CHARTS

SKIP_CHARTS=0

mkdir -p helm/

for CHART in "${HELM_CHARTS[@]}" ; do
  # don't process commented out helm charts
  [[ ${CHART:0:1} = \# ]] && continue

  # skip helm charts
  [[ ${SKIP_CHARTS} -gt 0 ]] && ((SKIP_CHARTS--)) && continue

  # parse chart data
  CHART_DATA=($CHART)
  CHART_URL="${CHART_DATA[0]}"
  CHART_REPO="${CHART_DATA[1]}"
  CHART_NAME="${CHART_DATA[2]}"
  CHART_VERSION="${CHART_DATA[3]}"

  # add helm repo
  helm repo add ${CHART_REPO} ${CHART_URL} 

  # create folder for helm chart
  mkdir -p helm/${CHART_NAME}/

  # pull helm chart
  helm pull ${CHART_REPO}/${CHART_NAME} --version ${CHART_VERSION}

  # exit on pull error
  [[ $? != 0 ]] && exit 1

  # move helmchart to folder
  mv ${CHART_NAME}-${CHART_VERSION}.tgz helm/${CHART_NAME}/
done

################################################################################
# additional artefacts
mkdir -p artefact

# download kubeadm, kubectl and kubelet -> https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.28.md#node-binaries-1
wget https://dl.k8s.io/v1.28.0/kubernetes-node-linux-amd64.tar.gz -O - | tar xzf - -C artefact

# /etc/init.d/kubelet
cat - > artefact/init.d_kubelet <<EOF_INITD_KUBELET
#!/sbin/openrc-run
# Copyright 2016-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

supervisor=supervise-daemon
description="Kubelet, a Kubernetes node agent"

if [ -e /var/lib/kubelet/kubeadm-flags.env ]; then
        . /var/lib/kubelet/kubeadm-flags.env;
fi

command="/usr/bin/kubelet"
command_args="\${command_args} \${KUBELET_KUBEADM_ARGS}"
pidfile="\${KUBELET_PIDFILE:-/run/\${RC_SVCNAME}.pid}"
: \${output_log:=/var/log/\$RC_SVCNAME/\$RC_SVCNAME.log}
: \${error_log:=/var/log/\$RC_SVCNAME/\$RC_SVCNAME.log}

depend() {
        after net
        need cgroups
        want containerd crio
}
EOF_INITD_KUBELET

# /etc/conf.d/kubelet
cat - > artefact/conf.d_kubelet <<EOF_CONFD_KUBELET
command_args="--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --cgroup-driver=cgroupfs --config=/var/lib/kubelet/config.yaml"
EOF_CONFD_KUBELET

# cri-tools (crictl) -> https://github.com/kubernetes-sigs/cri-tools/releases/tag/v1.28.0
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.28.0/crictl-v1.28.0-linux-amd64.tar.gz -O - | tar xzf - -C artefact

# cni -> calico
wget https://github.com/projectcalico/cni-plugin/releases/download/v3.20.6/calico-amd64 -O artefact/calico
wget https://github.com/projectcalico/cni-plugin/releases/download/v3.20.6/calico-ipam-amd64 -O artefact/calico-ipam

# issuer for cert-manager (letsencrypt) -> issuer-letsencrypt.yaml
cat - > artefact/issuer-letsencrypt.yaml <<EOF_ISSUER
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
  namespace: cert-manager
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: $EMAIL
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
      - http01:
          ingress:
            class: nginx
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: cert-manager
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $EMAIL
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
       ingress:
         class: nginx
EOF_ISSUER

cat - > artefact/prom_values.yaml <<EOF_PROM_VALUES
alertmanager:
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: default
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
 
prometheus:
  prometheusSpec:
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: default
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
EOF_PROM_VALUES


################################################################################
# create setup.sh
cat - > setup.sh <<EOF_SETUP
#!/bin/sh

SETUP_START=\$(date +%s)

################################################################################
# specific setup routines for:
# - init cluster
# - init single
# - join controlplane
# - join worker
# - upgrade 
# - delete
echo "setup \$1 \$2 \$3"

INIT=false
JOIN=false
UPGRADE=false
DELETE=false

[ "\$1" = init ] && INIT=true
[ "\$1" = join ] && JOIN=true
[ "\$1" = upgrade ] && UPGRADE=true
[ "\$1" = delete ] && DELETE=true

CLUSTER=false
SINGLE=false
CONTROLPLANE=false
WORKER=false

[ "\$2" = cluster ] && CLUSTER=true
[ "\$2" = single ] && SINGLE=true
[ "\$2" = controlplane ] && CONTROLPLANE=true
[ "\$2" = worker ] && WORKER=true

################################################################################
# airgap no repos
echo "# airgap no repos" > /etc/apk/repositories

################################################################################
# add kernel module for networking stuff
echo "br_netfilter" > /etc/modules-load.d/k8s.conf
modprobe br_netfilter
echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
sysctl net.bridge.bridge-nf-call-iptables=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl net.ipv4.ip_forward=1

################################################################################
# disable swap
sed -ie '/swap/ s/^/#/' /etc/fstab
swapoff -a

################################################################################
# fix prometheus errors
mount --make-rshared /
echo "#!/bin/sh" > /etc/local.d/sharedmetrics.start
echo "mount --make-rshared /" >> /etc/local.d/sharedmetrics.start
chmod +x /etc/local.d/sharedmetrics.start
rc-update add local default

################################################################################
# install packages
PACKAGES=\$(find alpine -name "*.apk")
apk add --repositories-file=/dev/null --allow-untrusted --no-network --no-cache \$PACKAGES

################################################################################
# install kubeadm, kubectl and kubelet
cp artefact/kubernetes/node/bin/kubeadm /usr/bin/kubeadm
chmod 755 /usr/bin/kubeadm

cp artefact/kubernetes/node/bin/kubectl /usr/bin/kubectl
chmod 755 /usr/bin/kubectl

cp artefact/kubernetes/node/bin/kubelet /usr/bin/kubelet
chmod 755 /usr/bin/kubelet

cp artefact/init.d_kubelet /etc/init.d/kubelet
chmod 755 /etc/init.d/kubelet

cp artefact/conf.d_kubelet /etc/conf.d/kubelet

mkdir -p /var/log/kubelet

################################################################################
# install cri-tools (crictl)
cp artefact/crictl /usr/bin/crictl
chmod 755 /usr/bin/crictl

################################################################################
# install calico cni modules
cp artefact/calico /usr/libexec/cni/calico
chmod 755 /usr/libexec/cni/calico

cp artefact/calico-ipam /usr/libexec/cni/calico-ipam
chmod 755 /usr/libexec/cni/calico-ipam

################################################################################
# add services and start container runtime
rc-update add kubelet
rc-update add containerd

# fix pause container use same version as kubernetes
sed -i 's/pause:3.8/pause:3.9/' /etc/containerd/config.toml
/etc/init.d/containerd start && sleep 5

################################################################################
# import container images
echo "Be patient import container images ..."
ctr -n=k8s.io image import container/images.tar

# fix crictl errors  
echo "runtime-endpoint: unix:///run/containerd/containerd.sock" > /etc/crictl.yaml
echo "image-endpoint: unix:///run/containerd/containerd.sock" >> /etc/crictl.yaml
echo "timeout: 2" >> /etc/crictl.yaml
echo "debug: false" >> /etc/crictl.yaml
echo "pull-image-on-create: false" >> /etc/crictl.yaml

# fix openebs udev probe error
mkdir -p /run/udev

################################################################################
# init
if [ \$INIT = true ] ; then
  echo "init kubernetes cluster ..."

  ################################################################################
  # init cluster
  CONTROL_PLANE_ENDPOINT=\$(ip -brief address show eth0 | awk '{print \$3}' | awk -F/ '{print \$1}')
  kubeadm init \
    --pod-network-cidr=$POD_NETWORK_CIDR \
    --service-cidr=$SERVICE_CIDR \
    --kubernetes-version=$VERSION \
    --upload-certs \
    --control-plane-endpoint=\$CONTROL_PLANE_ENDPOINT \
    --node-name=\$HOSTNAME
  [ \$? != 0 ] && echo "error: can't initialize cluster" && exit 1

  ################################################################################
  # copy kube config
  mkdir ~/.kube
  ln -s /etc/kubernetes/admin.conf ~/.kube/config
fi

################################################################################
# cluster
if [ \$CLUSTER = true ] ; then
  echo "init cluster settings"

  ################################################################################
  # install projectcalico tigera-operator v3.26.1
  helm upgrade --install tigera-operator helm/tigera-operator/tigera-operator-v3.26.1.tgz \
    --create-namespace \
    --namespace tigera-operator \
    --version v3.26.1
fi

################################################################################
# single
if [ \$SINGLE = true ] ; then
  echo "single node cluster settings"

  ################################################################################
  # remove no schedule taint for control plane
  kubectl taint nodes \$HOSTNAME node-role.kubernetes.io/control-plane=:NoSchedule-

  ################################################################################
  # install projectcalico tigera-operator v3.26.1
  helm upgrade --install tigera-operator helm/tigera-operator/tigera-operator-v3.26.1.tgz \
    --create-namespace \
    --namespace tigera-operator \
    --version v3.26.1

  ################################################################################
  # install openebs openebs 3.8.0
  helm upgrade --install openebs helm/openebs/openebs-3.8.0.tgz \
    --create-namespace \
    --namespace openebs \
    --version 3.8.0

  # set default storage class
  kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

  ################################################################################
  # install ingress-nginx controller
  helm upgrade --install ingress-nginx helm/ingress-nginx/ingress-nginx-4.7.1.tgz \
    --create-namespace \
    --namespace ingress-nginx \
    --version 4.7.1 \
    --set controller.service.type=NodePort \
    --set controller.service.nodePorts.http=30080 \
    --set controller.service.nodePorts.https=30443

  ################################################################################
  # install cert-manager
  helm upgrade --install cert-manager helm/cert-manager/cert-manager-v1.12.3.tgz \
    --create-namespace \
    --namespace cert-manager \
    --version v1.12.3 \
    --set installCRDs=true

  kubectl apply -f artefact/issuer-letsencrypt.yaml

  ################################################################################
  # alertmanager, prometheus and grafana 
  helm upgrade --install kube-prometheus-stack helm/kube-prometheus-stack/kube-prometheus-stack-48.3.1.tgz \
    --create-namespace \
    --namespace kube-prometheus-stack \
    --version 48.3.1 \
    --set alertmanager.service.type=NodePort \
    --set prometheus.service.type=NodePort \
    --set kubeProxy.service.selector.k8s-app=kube-proxy \
    --set kubeEtcd.service.selector.component=etcd \
    --values artefact/prom_values.yaml
fi

################################################################################
# join worker
if [ \$JOIN = true ] && [ \$WORKER = true ] ; then
  ssh -oBatchMode=yes -q \$3 exit
  if [ \$? = 0 ] ; then
    mkdir -p ~/.kube
    scp \$3:~/.kube/config ~/.kube/config
    JOIN_WORKER=\$(ssh -oBatchMode=yes \$3 kubeadm token create --print-join-command)
    eval \$JOIN_WORKER
  else
    echo "error: can't connect to \$3 via ssh"
    exit 1
  fi

  ################################################################################
  # TODO storage openebs mayastore

  ################################################################################
  # install ingress-nginx controller
  helm upgrade --install ingress-nginx helm/ingress-nginx/ingress-nginx-4.7.1.tgz \
    --create-namespace \
    --namespace ingress-nginx \
    --version 4.7.1 \
    --set controller.service.type=NodePort \
    --set controller.service.nodePorts.http=30080 \
    --set controller.service.nodePorts.https=30443

  ################################################################################
  # install cert-manager
  helm upgrade --install cert-manager helm/cert-manager/cert-manager-v1.12.3.tgz \
    --create-namespace \
    --namespace cert-manager \
    --version v1.12.3 \
    --set installCRDs=true

  kubectl apply -f artefact/issuer-letsencrypt.yaml
fi

################################################################################
# join controlplane
if [ \$JOIN = true ] && [ \$CONTROLPLANE = true ] ; then
  ssh -oBatchMode=yes -q \$3 exit
  if [ \$? = 0 ] ; then
    mkdir -p ~/.kube
    scp \$3:~/.kube/config ~/.kube/config
    CERTIFICATE_KEY=\$(ssh -oBatchMode=yes \$3 kubeadm init phase upload-certs --upload-certs | tail -1)
    JOIN_CONTROLPLANE=\$(ssh -oBatchMode=yes \$3 kubeadm token create --print-join-command --certificate-key \$CERTIFICATE_KEY)
    eval \$JOIN_CONTROLPLANE
  else
    echo "error: can't connect to \$3 via ssh"
    exit 1
  fi
fi

################################################################################
# upgrade
if [ \$UPGRADE = true ] ; then
  echo "upgrade not implemented"
fi

################################################################################
# delete
if [ \$DELETE = true ] ; then
  echo "delete not implemented"
fi

################################################################################
# cleanup
rm -rf setup.sh alpine/ container/ artefact/ # helm/  

################################################################################
# finish
SETUP_END=\$(date +%s)
SETUP_MINUTES=\$(echo "(\$SETUP_END - \$SETUP_START) / 60" | bc)
SETUP_SECONDS=\$(echo "\$SETUP_END - \$SETUP_START - (\$SETUP_MINUTES * 60)" | bc)

echo "setup took \$SETUP_MINUTES minutes \$SETUP_SECONDS seconds"

EOF_SETUP

chmod +x setup.sh

################################################################################
# create self extracting archive
NAME="kuba-setup"
TAR_FILE="${NAME}-${VERSION}.tgz"
SELF_EXTRACTABLE="$TAR_FILE.self"
PACK=true

if [[ ${PACK} = true ]] ; then
  echo "Be patient creating self extracting archive ..."
  # pack and create self extracting archive
  tar -czf ${TAR_FILE}  setup.sh alpine/ container/ artefact/ helm/

  echo '#!/bin/sh' > $SELF_EXTRACTABLE
  echo 'echo Be patient extracting archive ...' >> $SELF_EXTRACTABLE
  echo 'dd bs=`head -5 $0 | wc -c` skip=1 if=$0 | gunzip -c | tar -x' >> $SELF_EXTRACTABLE
  echo 'exec ./setup.sh $1 $2 $3' >> $SELF_EXTRACTABLE
  echo '######################################################################' >> $SELF_EXTRACTABLE

  cat $TAR_FILE >> $SELF_EXTRACTABLE
  chmod a+x $SELF_EXTRACTABLE
fi

################################################################################
# cleanup
CLEANUP=true

if [[ ${CLEANUP} = true ]] ; then
  rm -rf $TAR_FILE setup.sh alpine/ container/ artefact/ helm/
fi

################################################################################
# finish
BUILD_END=$(date +%s)
BUILD_MINUTES=$(echo "($BUILD_END - $BUILD_START) / 60" | bc)
BUILD_SECONDS=$(echo "$BUILD_END - $BUILD_START - ($BUILD_MINUTES * 60)" | bc)

echo "build $SELF_EXTRACTABLE took $BUILD_MINUTES minutes $BUILD_SECONDS seconds"
