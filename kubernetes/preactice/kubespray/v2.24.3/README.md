# kubespray-v2.23.1
* nodes
  + installer: `u20-node-00`
  + master: `u20-node-01`
  + worker: `u20-node-02` ~ `u20-node-04`

## installation

### installer
1. Change `installer` hostname
    * ```shell
      hostnamectl set-hostname u20-node-00
      ```
2. configure hosts for all nodes
    * ```shell
      cat >> /etc/hosts <<EOF
      # cluster nodes
      10.105.20.28 u20-node-01
      10.105.20.29 u20-node-02
      10.105.20.30 u20-node-03
      10.105.20.31 u20-node-04
      EOF
      ```
3. 
    * ```shell
      hostnamectl set-hostname u20-node-00
      ```
2. change hostname
* [k8s-installation](k8s-installation.md)