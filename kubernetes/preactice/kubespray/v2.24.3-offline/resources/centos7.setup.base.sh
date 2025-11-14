#! /bin/bash


      yum install -y vim curl net-tools containerd.io-1.6.26 \
          docker-ce-20.10.24 docker-ce-cli-20.10.24 docker-ce-rootless-extras-20.10.24 \
          && systemctl enable docker && systemctl start docker

set -e
set -x
apt-get install -y lvm2 docker-ce nfs-kernel-server kubelet=1.25.6-00 kubeadm=1.25.6-00 kubectl=1.25.6-00 python3 nvidia-docker2 nvidia-container-toolkit \
    && sed -i -Ee 's#^(ExecStart=/usr/bin/dockerd .*$)#\1 --exec-opt native.cgroupdriver=systemd#g' /usr/lib/systemd/system/docker.service \
    && sed -i '$i\    ,"default-runtime": "nvidia"' /etc/docker/daemon.json \
    && systemctl enable docker \
    && systemctl daemon-reload \
    && systemctl start docker
if [ -f "/etc/fstab" ]; then
    sed -i -Ee 's/^([^#].+ swap[ \t].*)/#\1/' /etc/fstab
fi
swapoff -a
if [ -f "/etc/containerd/config.toml" ]; then
    sed -i -Ee 's/^disabled_plugins\ \=/\#disabled_plugins\ \=/g' /etc/containerd/config.toml
fi
systemctl restart containerd
cat > /usr/lib/systemd/system/cri-docker.service <<EOF
[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket
[Service]
Type=notify
ExecStart=/usr/bin/cri-dockerd --network-plugin=cni --pod-infra-container-image=registry.k8s.io/pause:3.8
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
[Install]
WantedBy=multi-user.target
EOF
cat > /usr/lib/systemd/system/cri-docker.socket <<EOF
[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service
[Socket]
ListenStream=%t/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker
[Install]
WantedBy=sockets.target
EOF
systemctl daemon-reload
systemctl enable cri-docker.service
systemctl restart cri-docker.service
systemctl enable --now cri-docker.socket
systemctl status cri-docker.socket
systemctl status docker
cat > /etc/modules-load.d/k8s.conf <<EOF
br_netfilter
EOF
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system
systemctl enable kubelet
systemctl start kubelet

