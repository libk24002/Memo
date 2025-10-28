## zjvis-node

### network bond0
1. modify `/etc/sysconfig/network-scripts/ifcfg-eno1`
    * ```text
      TYPE=Ethernet
      BOOTPROTO=none
      USERCTL=no
      MASTER=bond0
      SLAVE=yes
      DEVICE=eno1
      ONBOOT=yes
      ```
2. modify `/etc/sysconfig/network-scripts/ifcfg-eno2`
    * ```text
      TYPE=Ethernet
      BOOTPROTO=none
      USERCTL=no
      MASTER=bond0
      SLAVE=yes
      DEVICE=eno2
      ONBOOT=yes
      ```
3. touch file `/etc/sysconfig/network-scripts/ifcfg-bond0`
    * ```text
      DEVICE=bond0
      ONBOOT=yes
      IPADDR=10.105.20.26
      BOOTPROTO=none
      NETMASK=255.255.255.0
      GATEWAY=10.105.20.254
      DNS1=10.255.9.2
      TYPE=bond
      USERCTL=no
      ```
4. restart network `bond0` `eno1` `eno2`
    * ```shell
      ifup bond0
      ifdown eno1 eno2 
      ifup eno1 eno2 
      ```

## install basic
1. install basic module
    * ```shell
      yum install -y vim net-tools device-mapper-persistent-data lvm2 docker-ce python3 iproute-tc \
          && systemctl start docker && systemctl enable docker
      ```
2. stop and disable firewalld
    * ```shell
      systemctl stop firewalld && systemctl disable firewalld
      ```
