_# k8s installation

## install basic
1. 3 node with `centos7`
    * master: `k8s-01`
    * worker1: `k8s-02`
    * worker2: `k8s-03`
2. configure hosts for all nodes
    * ```shell
      cat >> /etc/hosts <<EOF
      192.168.31.11 k8s-01
      192.168.31.12 k8s-02
      192.168.31.13 k8s-03
      EOF
      ```
3. remove all repo configuration
    * ```shell
      rm -rf /etc/yum.repos.d/*
      ```
4. configure ntp
    * ```shell
      yum install -y chrony && systemctl enable chronyd && systemctl start chronyd \
         && chronyc sources && chronyc tracking \
         && timedatectl set-timezone 'Asia/Shanghai'
      ```
5. stop and disable firewalld
    * ```shell
      systemctl stop firewalld && systemctl disable firewalld
      ```
6. install base environment
    * prepare [setup.bash.sh](resources/setup.bash.sh.md) as file `/tmp/setup.base.sh`
    * ```shell
      bash /tmp/setup.base.sh
      ```
7. prepare images at every node
    * ```shell
      DOCKER_IMAGE_PATH=/root/docker-images && mkdir -p $DOCKER_IMAGE_PATH
      BASE_URL="https://resource.cnconti.cc:32443/docker-images"
      for IMAGE in "docker.io_calico_apiserver_v3.21.2.dim" \
          "docker.io_calico_pod2daemon-flexvol_v3.21.2.dim" \
          "docker.io_calico_cni_v3.21.2.dim" \
          "docker.io_calico_typha_v3.21.2.dim" \
          "docker.io_calico_kube-controllers_v3.21.2.dim" \
          "docker.io_calico_node_v3.21.2.dim" \
          "docker.io_k8s.gcr.io_kube-apiserver_v1.23.3.dim" \
          "docker.io_k8s.gcr.io_pause_3.6.dim" \
          "docker.io_k8s.gcr.io_kube-controller-manager_v1.23.3.dim" \
          "docker.io_k8s.gcr.io_coredns_coredns_v1.8.6.dim" \
          "docker.io_k8s.gcr.io_kube-proxy_v1.23.3.dim" \
          "docker.io_k8s.gcr.io_etcd_3.5.1-0.dim" \
          "docker.io_k8s.gcr.io_kube-scheduler_v1.23.3.dim" \
          "quay.io_tigera_operator_v1.29.0.dim" \
          "docker.io_bitnami_mariadb_10.5.12-debian-10-r0.dim"
      do
          IMAGE_FILE=$DOCKER_IMAGE_PATH/$IMAGE 
          if [ ! -f $IMAGE_FILE ]; then
              TMP_FILE=$IMAGE_FILE.tmp \
              && curl -o "$IMAGE_FILE" -L "$BASE_URL/$IMAGE" \
              && mv $TMP_FILE $IMAGE_FILE
          fi
          docker image load -i $IMAGE_FILE && rm -f $IMAGE_FILE
      done
      ```

## install k8s-master
1. choose `k8s-01` as master node
2. initialize master
    * ```shell
      kubeadm init --pod-network-cidr=172.21.0.0/20 --kubernetes-version v1.23.3 \
          && systemctl restart kubelet
      ```
3. prepare `k8s-config`
    * ```shell
      mkdir -p $HOME/.kube
      cp /etc/kubernetes/admin.conf $HOME/.kube/config
      chown $(id -u):$(id -g) $HOME/.kube/config
      ```
4. download specific helm binary
    * ```shell
      BASE_URL="https://resource.cnconti.cc:32443/binary"
      USER_BIN=${HOME}/bin && mkdir -p ${USER_BIN} \
          && echo 'export PATH=$PATH:${HOME}/bin' > ${HOME}/.bashrc \
          && export PATH=$PATH:${HOME}/bin
      if [ ! -f $USER_BIN/helm ]; then
          curl -LO ${BASE_URL}/helm/v3.9.4/helm-v3.9.4-linux-amd64.tar.gz \
          && tar zxvf helm-v3.9.4-linux-amd64.tar.gz linux-amd64/helm \
          && mv linux-amd64/helm $USER_BIN/helm \
          && rm -rf linux-amd64/ helm-v3.9.4-linux-amd64.tar.gz
      fi
      ```
5. install `tigera-operator` by helm
    * prepare [tigera-operator.values.yaml](resources/tigera-operator.values.yaml.md)
    * ```shell
      helm install \
         --create-namespace --namespace calico-system \
         tigera-operator \
         https://resource.cnconti.cc:32443/charts/projectcalico.docs.tigera.io/charts/tigera-operator/tigera-operator-v3.25.0.tgz \
         --values /tmp/tigera-operator.values.yaml \
         --atomic
      ```
6. wait for all pods in kube-system to be ready
    * ```shell
      kubectl -n calico-system wait --for=condition=ready pod --all
      kubectl -n kube-system wait --for=condition=ready pod --all
      kubectl wait --for=condition=ready node --all
      ```
      
## install k8s-worker
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
