## NFS

### Installation
1. Prepare local storage for NFS services
    * ```shell
      mkdir -p $(pwd)/nfs/data \
          && echo '/data *(rw,fsid=0,no_subtree_check,insecure,no_root_squash)' > $(pwd)/nfs/exports
      ```
2. Load the NFS kernel of the work node
    * ```shell
      modprobe nfs && modprobe nfsd
      ```
3. Install `NFS service` using Docker
    * ```shell
      docker run --name nfs4 \
          --privileged \
          --restart always \
          -p 2049:2049 \
          -v $(pwd)/nfs/data:/data \
          -v $(pwd)/nfs/exports:/etc/exports:ro \
          -d docker.io/erichough/nfs-server:2.2.1
      ```

### Perform mount testing on the target node
* ```shell
  # you may need nfs-utils
  # for centos:
  # yum install nfs-utils
  # for ubuntu:
  # apt-get install nfs-common
  mkdir -p $(pwd)/mnt/nfs \
      && mount -t nfs4 -v localhost:/ $(pwd)/mnt/nfs
  ```

### Cleanup
1. Delete nfs4 container
    * ```shell
      docker stop nfs4 && docker rm nfs4
      ```
2. Clean nfs data
