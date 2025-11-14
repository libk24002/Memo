## ZJU Simulation
* CNAME: `simulation.zju.cnconti.tech` : `simul-entrance.zju.cnconti.tech`
* kubernetes: `v1.28.15`
* node-os: `ubuntu-22.04`
* role
    + master: `10.72.252.83`
    + worker: `10.72.252.16`, `10.72.252.234`

## k8s_installation
1. configure hosts for all nodes
    * ```shell
      cat >> /etc/hosts <<EOF
      # simulation
      192.168.6.83  simul-105-01
      192.168.6.16  simul-105-02
      192.168.6.234 simul-105-03
      EOF
      ```
2. stop and disable firewalld
    * ```shell
      systemctl stop firewalld && systemctl disable firewalld
      ```
3. configure repo
    * ```shell
      cat > /etc/apt/sources.list.d/kubernetes.list <<EOF
      # docker-ce
      deb [signed-by=/etc/apt/keyrings/docker-ce.gpg] https://download.docker.com/linux/ubuntu jammy stable
      # kubernetes
      deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /
      EOF
      ```
    * ```shell
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker-ce.gpg
      curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
      ```
4. Disable `swap`
    * ```shell
      swapoff -a && sed -i '/swap/d' /etc/fstab
      ```
5. install kubernetes and docker-ce
    * ```shell
      apt update && apt install -y lvm2 kubelet=1.28.15-1.1 kubeadm=1.28.15-1.1 kubectl=1.28.15-1.1 python3 containerd nfs-common
      ```
6. Kernel Module and Sysctl Configuration for Kubernetes Networking
    * ```shell
      cat > /etc/modules-load.d/k8s.conf <<EOF
      br_netfilter
      EOF
      ```
    * ```shell
      cat > /etc/sysctl.d/kubernetes.conf <<EOF
      fs.inotify.max_user_instances = 8192
      net.bridge.bridge-nf-call-ip6tables = 1
      net.bridge.bridge-nf-call-iptables = 1
      net.ipv4.ip_forward = 1
      EOF
      ```
7. enable & restart `containerd`
    * ```shell
      systemctl enable containerd && systemctl restart containerd
      ```
8. enable & restart `kubelet`
    * ```shell
      systemctl enable kubelet && systemctl restart kubelet
      ```
9. configure `containerd`
    * Generate containerd default configuration and append it to the configuration file
        + ```shell
          mkdir /etc/containerd && containerd config default > /etc/containerd/config.toml
          ```
    * Let containerd use systemd to manage cgroup, keeping it consistent with kubelet
        + ```shell
          sed -i -Ee 's/SystemdCgroup\ \=\ false/SystemdCgroup\ \=\ true/g' /etc/containerd/config.toml
          ```
    * Ensure that containerd and kubelet use the same sandbox image version
        + ```shell
          sed -i -Ee 's/sandbox_image\ \=\ \"registry.k8s.io\/pause\:3.8\"/sandbox_image\ \=\ \"registry.k8s.io\/pause\:3.10\"/g' /etc/containerd/config.toml
          ```
    * restart `contained` & kubelet
        + ```shell
          systemctl restart containerd && systemctl restart kubelet
          ```

### install k8s-master
1. Initialize master
    * choose `simul-105-01` as `control-plane-endpoint`
    * ```shell
      kubeadm init --kubernetes-version=v1.28.15 --upload-certs \
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
1. choose `simul-105-02` and `simul-105-03` as worker node
    * ```shell
      $(ssh simul-105-01 "kubeadm token create --print-join-command")
      ```
2. wait for all pods in kube-system to be ready
    * ```shell
      kubectl -n calico-system wait --for=condition=ready pod --all
      kubectl -n kube-system wait --for=condition=ready pod --all
      kubectl wait --for=condition=ready node --all
      ```

### install nfs-provisioner
1. install `nfs-provisioner`
    * ```shell
      helm install \
          --create-namespace --namespace nfs-provisioner \
          my-nfs-subdir-external-provisioner \
          ./resources/charts/nfs-subdir-external-provisioner-4.0.14.tgz \
          --values ./resources/nfs-provisioner.values.yaml \
          --atomic
      ```
2. test `nfs-provisioner` by `mariadb`
    * install by helm
        + ```shell
          helm install \
              --create-namespace --namespace test \
              test-mariadb \
              ./resources/charts/mariadb-9.4.2.tgz \
              --values ./resources/test-mariadb.values.yaml \
              --timeout 600s \
              --atomic
          ```
    * connect to mariadb with in the pod
        + ```shell
          MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace test test-mariadb-mariadb \
              -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)
          kubectl run test-mariadb-client \
              --rm --tty -i \
              --restart='Never' \
              --image docker.io/bitnami/mariadb:10.5.12-debian-10-r0 \
              --namespace test \
              --env MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
              --command -- bash -c \
              'echo "show databases;" | mysql -h test-mariadb-mariadb.test.svc.cluster.local \
                   -uroot -p$MYSQL_ROOT_PASSWORD my_database'
          ```
    * uninstall `mariadb-test`
        + ```shell
          helm -n test uninstall test-mariadb \
              && kubectl -n test delete pvc data-test-mariadb-0\
              && kubectl delete namespace test
          ```

### install basic
1. install `ingress-nginx`
    * ```shell
      helm install \
          --create-namespace --namespace basic-components \
          my-ingress-nginx \
          ./resources/charts/ingress-nginx-4.0.5.tgz \
          --values ./resources/ingress-nginx.values.yaml \
          --atomic
      ```
2. install `cert-manager`
    * install by helm
        + ```shell
          helm install \
              --create-namespace --namespace basic-components \
              my-cert-manager \
              ./resources/charts/cert-manager-v1.5.4.tgz \
              --values ./resources/cert-manager.values.yaml \
              --atomic
          ```
    * create cluster issuer `self-signed-cluster-issuer`
        + ```shell
          kubectl -n basic-components apply -f ./resources/self-signed-clusterissuer.clusterissuer.yaml
          ```

### install middleware
1. install `mariadb`
    * install by helm
        + ```shell
          helm install \
              --create-namespace --namespace middleware \
              my-mariadb \
              ./resources/charts/mariadb-9.4.2.tgz \
              --values ./resources/mariadb.values.yaml \
              --atomic
          ```
    * apply `mariadb-tool`
        + ```shell
          kubectl -n middleware apply -f ./resources/mariadb-tool.deployment.yaml
          ```
    * test `mariadb`
        + ```shell
          kubectl -n middleware exec -it deployment/mariadb-tool -- bash -c \
              'echo "show databases" | mysql -h my-mariadb.middleware -uroot -p$MARIADB_ROOT_PASSWORD'
          ```
2. install `minio`
    * install by helm
        + ```shell
          helm install \
              --create-namespace --namespace middleware \
              my-minio \
              ./resources/charts/minio-11.9.2.tgz \
              --values ./resources/minio.values.yaml \
              --atomic
          ```
    * apply `minio-tools`
        + ```shell
          kubectl -n middleware apply -f /resources/minio-tool.deployment.yaml
          ```
3. install `redis-cluster`
    * install by helm
        + ```shell
          helm install \
              --create-namespace --namespace middleware \
              my-redis-cluster \
              ./resources/charts/redis-cluster-5.0.1.tgz \
              --values ./resources/redis-cluster.values.yaml \
              --atomic
          ```
4. install `nacos`
    * install by helm
        + ```shell
          helm install \
              --create-namespace --namespace application \
              nacos \
              ./resources/charts/nacos-2.1.4.tgz \
              --values ./resources/nacos.values.yaml \
              --atomic
          ```

### initialization middleware
1. initialize the `mariadb`
    * prepare `simulation.initialize.mariadb.20250716.sql`
    * initialization `mariadb` database `simulation`
        + ```shell
          export SQL_FILENAME="simulation.initialize.mariadb.20250716.sql"  
          export POD_NAME=$(kubectl get pod -n middleware -l "app.kubernetes.io/name=mariadb-tool" -o jsonpath="{.items[0].metadata.name}")
          kubectl -n middleware cp ./resources/${SQL_FILENAME} ${POD_NAME}:/tmp/${SQL_FILENAME} \
              && kubectl -n middleware exec -it deployment/mariadb-tool -- bash -c \
                  'echo "create database simulation;" | mysql -h my-mariadb.middleware -uroot -p$MARIADB_ROOT_PASSWORD' \
              && kubectl -n middleware exec -it ${POD_NAME} -- bash -c \
                  "mysql -h my-mariadb.middleware -uroot -p\${MARIADB_ROOT_PASSWORD} simulation < /tmp/simulation.initialize.mariadb.20250716.sql"
          ```

### install business
1. install `simulation-backend`
    * prepare `simulation-backend.values.yaml`
    * install by helm
        + ```shell
          helm install \
              --create-namespace --namespace simulation \
              simulation-backend \
              ./resources/charts/java-1.0.0-C4f979aa.tgz \
              --values ./resources/simulation-backend.values.yaml \
              --atomic
          ```
2. install `simulation-frontend`
    * prepare `simulation-frontend.values.yaml`
    * install by helm
        + ```shell
          helm install \
              --create-namespace --namespace simulation \
              simulation-frontend \
              ./resources/charts/nginx-1.0.0-C59112ee.tgz \
              --values ./resources/simulation-frontend.values.yaml \
              --atomic
          ```
