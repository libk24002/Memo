## k8s installation
* kubernetes: `v1.32.5`
* node-os: `ubuntu-22.04`
* role
  + master: `stick-001`, `stick-002`, `stick-003`
  + worker: `stick-004` ~ `stick-005`

### install basic
1. configure hosts for all nodes
    * ```shell
      cat >> /etc/hosts <<EOF
      192.168.31.11 stick-001
      192.168.31.12 stick-002
      192.168.31.13 stick-003
      192.168.31.14 stick-004
      192.168.31.15 stick-005
      EOF
      ```
2. configure repo
    * ```shell
      cat > /etc/apt/sources.list <<EOF
      deb https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
      deb-src https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
      
      deb https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
      deb-src https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
      
      deb https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
      deb-src https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
      
      deb https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
      deb-src https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
      
      # kubernetes
      deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.32/deb/ /
      EOF
      ```
    * ```shell
      curl -fsSL https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
      ```
3. Disable `swap`
    * ```shell
      swapoff -a && sed -i '/swap/d' /etc/fstab
      ```
4. Kernel Module and Sysctl Configuration for Kubernetes Networking
    * ```shell
      cat > /etc/modules-load.d/k8s.conf <<EOF
      br_netfilter
      EOF
      ```
    * ```shell
      cat > /etc/sysctl.d/kubernetes.conf <<EOF
      net.bridge.bridge-nf-call-ip6tables = 1
      net.bridge.bridge-nf-call-iptables = 1
      net.ipv4.ip_forward = 1
      EOF
      ```
5. enable & restart `containerd`
    * ```shell
      systemctl enable containerd && systemctl restart containerd
      ```
6. enable & restart `kubelet`
    * ```shell
      systemctl enable kubelet && systemctl restart kubelet
      ```
7. configure `containerd`
    * 生成containerd 默认配置，并追加到配置文件
        + ```shell
          mkdir /etc/containerd && containerd config default > /etc/containerd/config.toml
          ```
    * 让 containerd 使用 systemd 管理 cgroup，保持和 kubelet 一致
        + ```shell
          sed -i -Ee 's/SystemdCgroup\ \=\ false/SystemdCgroup\ \=\ true/g' /etc/containerd/config.toml
          ```
    * 保证 containerd 与 kubelet 使用一致的 sandbox 镜像版本
        + ```shell
          sed -i -Ee 's/sandbox_image\ \=\ \"registry.k8s.io\/pause\:3.8\"/sandbox_image\ \=\ \"registry.k8s.io\/pause\:3.10\"/g' /etc/containerd/config.toml
          ```
    * restart `contained` & kubelet
        + ```shell
          systemctl restart containerd && systemctl restart kubelet
          ```

### install k8s-master
1. Initialize master
    * 选择 `stick-control.host.cnconti.tech` 作为 `control-plane-endpoint`
    * ```shell
      kubeadm init --kubernetes-version=v1.32.5 --upload-certs \
          --control-plane-endpoint stick-control.host.cnconti.tech:6443 \
      && systemctl restart kubelet
      ```
2. prepare `k8s-config`
    * ```shell
      mkdir -p $HOME/.kube
      cp /etc/kubernetes/admin.conf $HOME/.kube/config
      chown $(id -u):$(id -g) $HOME/.kube/config
      ```
3. download specific helm binary
    * ```shell
      HELM_BASE_URL="https://get.helm.sh/helm-v3.18.6-linux-amd64.tar.gz"
      USER_BIN=${HOME}/bin && mkdir -p ${USER_BIN} \
          && echo 'export PATH=$PATH:${HOME}/bin' > ${HOME}/.bashrc \
          && export PATH=$PATH:${HOME}/bin
      if [ ! -f $USER_BIN/helm ]; then
          curl -L $HELM_BASE_URL -o /tmp/helm.tar.gz \
          && tar zxvf /tmp/helm.tar.gz -C /tmp \
          && mv /tmp/linux-amd64/helm $USER_BIN/helm \
          && rm -rf /tmp/linux-amd64/ /tmp/helm.tar.gz
      fi
      ```
4. install `cilium` by helm
    * ```shell
      helm install \
          --namespace kube-system \
          cilium cilium \
          --repo https://helm.cilium.io/ \
          --version 1.17.4 \
          --set ipv4NativeRoutingCIDR=172.24.0.0/14 \
          --set ipam.operator.clusterPoolIPv4PodCIDRList=172.24.0.0/14
      ```
5. wait for all pods in kube-system to be ready
    * ```shell
      kubectl -n kube-system wait --for=condition=ready pod --all
      kubectl wait --for=condition=ready node --all
      ```
      
### install k8s-worker
1. choose `k8s-02` ~ `k8s-03` as worker node
    * ```shell
      $(ssh k8s-01 "kubeadm token create --print-join-command")
      ```
2. wait for all pods in kube-system to be ready
    * ```shell
      kubectl -n calico-system wait --for=condition=ready pod --all
      kubectl -n kube-system wait --for=condition=ready pod --all
      kubectl wait --for=condition=ready node --all
      ```

## install rook-ceph to provide storage class
1. what wo have 
    * `/dev/mapper/centos-rookmonitor` which have initialized as `xfs` in every node
    * `/dev/mapper/centos-rookdata` in every node
2. prepare images at every node
    * ```shell
      DOCKER_IMAGE_PATH=/root/docker-images && mkdir -p $DOCKER_IMAGE_PATH
      BASE_URL="https://resource.cnconti.cc:32443/docker-images"
      for IMAGE in "k8s.gcr.io_sig-storage_csi-attacher_v3.2.1.dim" \
          "k8s.gcr.io_sig-storage_csi-node-driver-registrar_v2.2.0.dim" \
          "k8s.gcr.io_sig-storage_csi-provisioner_v2.2.2.dim" \
          "k8s.gcr.io_sig-storage_csi-resizer_v1.2.0.dim" \
          "k8s.gcr.io_sig-storage_csi-snapshotter_v4.1.1.dim" \
          "k8s.gcr.io_sig-storage_local-volume-provisioner_v2.4.0.dim" \
          "quay.io_ceph_ceph_v16.2.5.dim" \
          "quay.io_cephcsi_cephcsi_v3.4.0.dim" \
          "docker.io_rook_ceph_v1.7.3.dim"
      do
          IMAGE_FILE=$DOCKER_IMAGE_PATH/$IMAGE
          if [ ! -f $IMAGE_FILE ]; then
              TMP_FILE=$IMAGE_FILE.tmp \
              && curl -o "$TMP_FILE" -L "$BASE_URL/$IMAGE" \
              && mv $TMP_FILE $IMAGE_FILE
          fi
          docker image load -i $IMAGE_FILE && rm -f $IMAGE_FILE
      done
      ```
3. prepare storage class `rook-monitor` by `local-static-provisioner`
    * prepare resources at every node except master node
        +  ```shell
           HOSTNAME=$(hostname)
           PREFIX=${HOSTNAME:0:11}
           mkdir -p /local-static-provisioner/rook-ceph/monitor/rook-$PREFIX-01
           echo "/dev/mapper/centos-rookmonitor /local-static-provisioner/rook-ceph/monitor/rook-$PREFIX-01 xfs defaults 0 0" >> /etc/fstab
           mount -a
           ```
    * prepare [local.rook.monitor.values.yaml](resources/local.rook.monitor.values.yaml.md) as file `/tmp/local.rook.monitor.values.yaml`
    * install `rook-monitor` by helm
        + ```shell
          helm install \
             --create-namespace --namespace local-disk \
             rook-monitor \
             https://resource.cnconti.cc:32443/charts/others/sig-storage-local-static-provisioner.v2.4.0.tar.gz \
             --values /tmp/local.rook.monitor.values.yaml \
             --atomic
          ```
4. prepare storage class `rook-data` by `local-static-provisioner`
    * prepare resources at every node except master node
        +  ```shell
           HOSTNAME=$(hostname)
           PREFIX=${HOSTNAME:0:11}
           mkdir -p /local-static-provisioner/rook-ceph/monitor/rook-$PREFIX-01
           ln -s /dev/mapper/centos-rookdata /local-static-provisioner/rook-ceph/data/rook-$PREFIX-01
           ```
    * prepare [local.rook.data.values.yaml ](resources/local.rook.data.values.yaml.md) as file `/tmp/local.rook.data.values.yaml`
    * install `rook-data` by helm
        + ```shell
          helm install \
             --create-namespace --namespace local-disk \
             rook-data \
             https://resource.cnconti.cc:32443/charts/others/sig-storage-local-static-provisioner.v2.4.0.tar.gz \
             --values /tmp/local.rook.data.values.yaml \
             --atomic
          ```
5. check pod healthy and pvs created
    * ```shell
      kubectl -n local-disk get pod
      kubectl -n local-disk wait --for=condition=ready pod --all
      kubectl get pv
      ```
6. install `rook-ceph-operator`
    * prepare [rook-ceph-operator.values.yaml](resources/rook-ceph-operator.values.yaml.md) as file `/tmp/rook-ceph-operator.values.yaml`
    * install `rook-ceph-operator` by helm
    * ```shell
      helm install \
          --create-namespace --namespace rook-ceph \
          my-rook-ceph-operator \
          https://resource.cnconti.cc:32443/charts/charts.rook.io/release/rook-ceph-v1.7.3.tgz \
          --values /tmp/rook-ceph-operator.values.yaml \
          --atomic
      ```
7. create `cephcluster` 
    * prepare [rook-ceph.cephcluster.yaml](resources/rook-ceph.cephcluster.yaml.md) as file `/tmp/rook-ceph.cephcluster.yaml`
    * ```shell
      kubectl -n rook-ceph apply -f /tmp/rook-ceph.cephcluster.yaml
      ```
8. create `rook-ceph-tools`
    * prepare [rook-ceph-tools.deployment.yaml](resources/rook-ceph-tools.deployment.yaml.md) as file `/tmp/rook-ceph-tools.deployment.yaml`
    * ```shell
      kubectl -n rook-ceph apply -f /tmp/rook-ceph-tools.deployment.yaml
      ```
9. create ceph filesystem and storage class
    * prepare [ceph-filesystem.yaml](resources/ceph-filesystem.yaml.md) as file `/tmp/ceph-filesystem.yaml`
    * ```shell
      kubectl -n rook-ceph apply -f /tmp/ceph-filesystem.yaml
      ```
    * prepare [rook-cephfs.storageclass.yaml](resources/rook-cephfs.storageclass.yaml.md) as file `/tmp/rook-cephfs.storageclass.yaml`
    * ```shell
      kubectl -n rook-ceph apply -f /tmp/rook-cephfs.storageclass.yaml
      ```
10. check `rook-ceph` status
    * ```shell
      # pgs(if exists any) should be active and clean
      kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- ceph status
      # one file system, which is active, is expected
      # in addition, check available storage size
      # 1 pool are expected
      kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- ceph fs status
      ```

## test k8s-cluster
1. prepare [test-mariadb.values.yaml](resources/test-mariadb.values.yaml) as file `/tmp/test-mariadb.values.yaml`
2. install `test-mariadb` by helm
    * ```shell
      helm install \
          --create-namespace --namespace test \
          test-mariadb \
          https://resource.cnconti.cc:32443/charts/charts.bitnami.com/bitnami/mariadb-9.4.2.tgz \
          --values /tmp/test-mariadb.values.yaml \
          --timeout 600s \
          --atomic
      ```
3. connect to maria-db
    * ```shell
      MYSQL_ROOT_PASSWORD=$(kubectl -n test get secret test-mariadb -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)
      kubectl run mariadb-client \
          --rm --tty -i \
          --restart='Never' \
          --image docker.io/bitnami/mariadb:10.5.12-debian-10-r0 \
          --namespace test \
          --env MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
          --command -- bash
      ```
    * ```shell
      echo "show databases;" | mysql -h test-mariadb.test.svc.cluster.local -uroot -p$MYSQL_ROOT_PASSWORD
      ```
4. check pvc and pv
    * ```shell
      kubectl -n test get pvc
      kubectl get pv
      ```
5. uninstall `test-mariadb`
    * ```shell
      helm -n test uninstall test-mariadb \
          && kubectl -n test delete pvc data-test-mariadb-0 \
          && kubectl delete namespace test
      ```_
