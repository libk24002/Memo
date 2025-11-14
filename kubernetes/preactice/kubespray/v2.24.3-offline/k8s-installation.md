## kubespray-offline-231220

### prepare
1. prepare 3 nodes with `Centos7`
    * master: 192.168.31.51 `operator`
    * worker1: 192.168.31.52
    * worker2: 192.168.31.53
2. resources info
    * kubespray-file #k8s部署相关的文件
    * kubespray-images #私有镜像仓库registry镜像及部署脚本
    * kubespray-v2.23.1 #官方kubespray-v2.23.0源码

### installation operator
1. configure repositories at every node
    * prepare `Centos7-base-231220.tar.gz` [Centos7-base](resources/Centos7-base.md)
    * prepare `Centos7-extras-231220.tar.gz` [Centos7-extras](resources/Centos7-extras.md)
    * prepare `Centos7-docker-ce-231220.tar.gz` [Centos7-docker-ce](resources/Centos7-docker-ce.md)
    * ```shell
      rm -rf /etc/yum.repos.d/* \
          && tar xvf Centos7-base-231220.tar.gz -c /data/base \
          && tar xvf Centos7-extras-231220.tar.gz -c /data/extras \
          && tar xvf Centos7-docker-ce-231220.tar.gz -c /data/docker-ce
      ```
    * prepare [centos7.offline.repo](resources/centos7.offline.repo) as file `/etc/yum.repos.d/centos7.offline.repo`
2. configure ntp at every node
    * ```shell
      yum install -y chrony && systemctl enable chronyd && systemctl start chronyd \
         && chronyc sources && chronyc tracking && timedatectl set-timezone 'Asia/Shanghai'
      ```
3. install base environment
    * prepare [centos7.setup.base.sh](resources/centos7.setup.base.sh.md) as file `/tmp/centos7.setup.base.sh`
    * ```shell
      bash /tmp/centos7.setup.base.sh
      ```
4. prepare images
    * prepare `kubespray-images-231220.tar.gz` [kubespray-images](resources/kubespray-images.md)
    * ```shell
      tar xvf kubespray-images-231220.tar.gz -C $HOME && \
      for IMAGE in "docker.io-library-nginx-1.25.2-alpine.dim" \
          "docker.io-library-registry-2.8.1.dim" \
          "quay.io-kubespray-kubespray-v2.23.1.dim"
      do
          docker image load -i $HOME/kubespray-images$IMAGE
      done
      ```
5. make `yum-registry`
    * prepare [yum-registry.nginx.conf](resources/yum-registry.nginx.conf.md) as file `/tmp/yum-registry.nginx.conf`
    * ```shell
      docker run \
          --name yum-registry \
          --restart always \
          -p 8001:80 \
          -v $PWD/yum-registry.nginx.conf:/etc/nginx/nginx.conf \
          -v /data/base:/usr/share/nginx/html/base \
          -v /data/extras:/usr/share/nginx/html/extras \
          -v /data/docker-ce:/usr/share/nginx/html/docker-ce \
          -d docker.io/library/nginx:1.25.2-alpine
      ```
6. make `file-registry`
    * prepare `kubespray-file-231220.tar.gz` [kubespray-file](resources/kubespray-file.md)
    * prepare [file-registry.nginx.conf](resources/file-registry.nginx.conf.md)
    * ```shell
      tar xvf kubespray-file-231220.tar.gz -C $HOME
      docker run \
          --name file-registry \
          --restart always \
          -p 8002:80 \
          -v $PWD/file-registry.nginx.conf:/etc/nginx/nginx.conf \
          -v $HOME/kubespray-file:/usr/share/nginx/html \
          -d docker.io/library/nginx:1.25.2-alpine
      ```
7. registering the images to local registry
    * prepare [upload-iamge.sh] as file `/tmp/upload-iamge.sh`
    * ```shell
      bash
      ```
8. clone kubespray with specific version `v2.23.1`
    * prepare `kubespray-v2.23.1.tar.gz` [kubespray-v2.23.1](resources/kubespray-v2.23.1.md)
    * ```shell
      tar xvf $HOME/kubespray-v2.23.1.tar.gz -C $HOME && \
      docker run --rm -it \
           --workdir /app \
           -v $HOME/kubespray-v2.23.1:/app \
           -v $HOME/.ssh:/root/.ssh:ro \
           quay.io/kubespray/kubespray:v2.23.1 bash
      ```
    * generate configurations for kubespray
    * ```shell
      cp -rfp inventory/sample inventory/mycluster
      declare -a IPS=(192.168.31.51 192.168.31.52 192.168.31.53)
      CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
      ```
    * stop and disable firewalld
    * ```shell
      ansible -i inventory/mycluster/hosts.yaml all -m command -a "systemctl stop firewalld"
      ansible -i inventory/mycluster/hosts.yaml all -m command -a "systemctl disable firewalld"
      ```
9. modify `$HOME/kubespray-v2.23.1/inventory/mycluster/group_vars/all/offline.yml`
    * `yum_repo: "http://192.168.31.51:8001"`
    * `files_repo: "http://192.168.31.51:8002"`
10. install kubernetes cluster with ansible
    * ```shell
      docker run --rm -it \
           --workdir /app \
           -v $HOME/kubespray-v2.23.1:/app \
           -v $HOME/.ssh:/root/.ssh:ro \
           quay.io/kubespray/kubespray:v2.23.1 bash
      ```
    * ```shell
      ansible-playbook -i inventory/mycluster/hosts.yaml --become --become-user=root reset.yml
      # you may have to retry several times to install kubernetes cluster successfully for the bad network
      ansible-playbook -i inventory/mycluster/hosts.yaml --become --become-user=root cluster.yml
      ```
11. copy configurations for kubectl
     * ```shell
       mkdir ~/.kube \
           && cp /etc/kubernetes/admin.conf ~/.kube/config \
           && chown $(id -u):$(id -g) $HOME/.kube/config
       ```
