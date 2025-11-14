#!/bin/bash

set -e
set -x

rm -rf /etc/yum.repos.d/*

cat > /etc/yum.repos.d/centos7-yum.repo <<EOF
[base]
name=CentOS-\$releasever - Base - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-\$releasever - Extras - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/\$releasever/extras/\$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7

[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=http://mirrors.aliyun.com/docker-ce/linux/centos/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/docker-ce/linux/centos/gpg
EOF

yum clean all && yum install -y yum-utils \
    && reposync -p /data --repo=base --download-metadata \
    && reposync -p /data --repo=extras --download-metadata \
    && reposync -p /data --repo=docker-ce-stable --download-metadata