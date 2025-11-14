# Centos7-yum231220
1. prepare [make-yum-registry.sh](make-yum-registry.sh.md)
3. running centos7 in docker
    * ```shell
      YUM_REGISTRY_DIR=/data/Centos7-yum && mkdir $YUM_REGISTRY_DIR
      docker run -ti --rm \
          -v $YUM_REGISTRY_DIR:/data \
          -v $PWD/make-yum-registry.sh:/make-yum-registry.sh \
          docker.io/library/centos:centos7.9.2009 \
          /bin/bash -c ''
      ```