## Minikube
minikube is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes.

All you need is Docker (or similarly compatible) container or a Virtual Machine environment, and Kubernetes is a single command away: `minikube start`

### What you’ll need
* 2 CPUs or more
* 2GB of free memory
* 20GB of free disk space
* Internet connection
 * Container or virtual machine manager, such as: Docker, QEMU, Hyperkit, Hyper-V, KVM, Parallels, Podman, VirtualBox, or VMware Fusion/Workstation

### Installation
1. Prepare minikube binary
    * ```shell
      MIRROR="files.m.daocloud.io/"
      curl -LO "https://${MIRROR}storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64" \
          && mkdir -p ${HOME}/bin \
          && mv minikube-linux-amd64 ${HOME}/bin/minikube \
          && chmod u+x ${HOME}/bin/minikube
      ```
2. Start minikube machine
    * ```shell
      minikube start \
          --driver=podman \
          --container-runtime=cri-o \
          --kubernetes-version=v1.27.10 \
          --image-mirror-country=cn \
          --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers \
          --cpus=6 \
          --memory=24g \
          --disk-size=100g
      ```

### Cleanup
1. delete minikube
    * ```shell
      minikube delete
      ```


