# QEMU/KVM 虚拟化技术

!!! info "QEMU 和 KVM 简介"
    QEMU 是一个开源的硬件虚拟化器，KVM（Kernel-based Virtual Machine）是 Linux 内核的虚拟化模块。两者结合可以提供接近原生性能的虚拟化解决方案。

## 📖 基础概念

### QEMU vs KVM

- **QEMU**: 纯软件虚拟化，可以模拟各种硬件架构
- **KVM**: 硬件辅助虚拟化，需要 CPU 支持（Intel VT-x 或 AMD-V）
- **QEMU + KVM**: QEMU 作为前端，KVM 提供硬件加速

### 虚拟化类型

| 类型 | 说明 | 性能 | 使用场景 |
|------|------|------|----------|
| 全虚拟化 | 完全模拟硬件 | 低 | 跨架构模拟 |
| 半虚拟化 | Guest 知道自己在虚拟化环境 | 中 | 需要修改 Guest |
| 硬件辅助虚拟化 | 使用 CPU 虚拟化扩展 | 高 | 生产环境 |

## 🚀 安装 QEMU/KVM

### Ubuntu/Debian

```bash
# 检查 CPU 是否支持虚拟化
egrep -c '(vmx|svm)' /proc/cpuinfo
# 输出大于 0 表示支持

# 安装 QEMU 和 KVM
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager

# 将当前用户添加到 libvirt 组
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER

# 启动 libvirtd 服务
sudo systemctl enable --now libvirtd
```

### CentOS/RHEL/Rocky Linux

```bash
# 检查虚拟化支持
lscpu | grep Virtualization

# 安装 QEMU 和 KVM
sudo dnf install -y qemu-kvm libvirt virt-install virt-viewer bridge-utils

# 启动服务
sudo systemctl enable --now libvirtd

# 验证安装
sudo virsh list --all
```

### Fedora

```bash
# 安装虚拟化组
sudo dnf install @virtualization

# 启动服务
sudo systemctl enable --now libvirtd

# 添加用户到组
sudo usermod -aG libvirt $USER
```

### macOS

```bash
# 使用 Homebrew 安装
brew install qemu

# 验证安装
qemu-system-x86_64 --version
```

## 💻 创建虚拟机

### 使用命令行创建

**创建磁盘镜像**:

```bash
# 创建 qcow2 格式的磁盘（推荐）
qemu-img create -f qcow2 ubuntu-server.qcow2 20G

# 查看磁盘信息
qemu-img info ubuntu-server.qcow2
```

**启动虚拟机安装系统**:

```bash
# 基本启动命令
qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 \
    -cpu host \
    -smp 2 \
    -boot d \
    -cdrom ubuntu-22.04-server.iso \
    -drive file=ubuntu-server.qcow2,format=qcow2 \
    -net nic -net user
```

**参数说明**:

- `-enable-kvm`: 启用 KVM 加速
- `-m 2048`: 分配 2GB 内存
- `-cpu host`: 使用宿主机 CPU 特性
- `-smp 2`: 分配 2 个 CPU 核心
- `-boot d`: 从光盘启动
- `-cdrom`: 指定 ISO 镜像
- `-drive`: 指定磁盘镜像

**安装完成后启动**:

```bash
qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 \
    -cpu host \
    -smp 2 \
    -drive file=ubuntu-server.qcow2,format=qcow2 \
    -net nic -net user,hostfwd=tcp::2222-:22
```

### 使用 virt-install 创建

```bash
# 创建 Ubuntu 虚拟机
virt-install \
    --name ubuntu-server \
    --ram 2048 \
    --vcpus 2 \
    --disk path=/var/lib/libvirt/images/ubuntu-server.qcow2,size=20 \
    --os-variant ubuntu22.04 \
    --network bridge=virbr0 \
    --graphics none \
    --console pty,target_type=serial \
    --location 'http://archive.ubuntu.com/ubuntu/dists/jammy/main/installer-amd64/' \
    --extra-args 'console=ttyS0,115200n8 serial'
```

**创建 CentOS 虚拟机**:

```bash
virt-install \
    --name centos-8 \
    --ram 4096 \
    --vcpus 4 \
    --disk path=/var/lib/libvirt/images/centos-8.qcow2,size=40,format=qcow2 \
    --os-variant centos8 \
    --network bridge=virbr0 \
    --cdrom /path/to/CentOS-Stream-8-x86_64-latest-dvd1.iso \
    --graphics vnc,listen=0.0.0.0 \
    --noautoconsole
```

## 🎮 虚拟机管理

### 使用 virsh 命令

```bash
# 列出所有虚拟机
virsh list --all

# 启动虚拟机
virsh start vm-name

# 关闭虚拟机
virsh shutdown vm-name

# 强制关闭
virsh destroy vm-name

# 重启虚拟机
virsh reboot vm-name

# 暂停虚拟机
virsh suspend vm-name

# 恢复虚拟机
virsh resume vm-name

# 删除虚拟机
virsh undefine vm-name

# 查看虚拟机信息
virsh dominfo vm-name

# 编辑虚拟机配置
virsh edit vm-name

# 连接到虚拟机控制台
virsh console vm-name
```

### 快照管理

```bash
# 创建快照
virsh snapshot-create-as vm-name snapshot-name "Snapshot description"

# 列出快照
virsh snapshot-list vm-name

# 恢复快照
virsh snapshot-revert vm-name snapshot-name

# 删除快照
virsh snapshot-delete vm-name snapshot-name

# 查看当前快照
virsh snapshot-current vm-name
```

## 🌐 网络配置

### NAT 网络（默认）

```bash
# 查看默认网络
virsh net-list --all

# 启动默认网络
virsh net-start default
virsh net-autostart default

# 查看网络详情
virsh net-info default
```

### 桥接网络

**创建网桥**:

```bash
# Ubuntu/Debian - 编辑 /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    enp1s0:
      dhcp4: no
  bridges:
    br0:
      interfaces: [enp1s0]
      dhcp4: yes
      
# 应用配置
sudo netplan apply
```

**CentOS/RHEL - 创建网桥配置文件**:

```bash
# /etc/sysconfig/network-scripts/ifcfg-br0
DEVICE=br0
TYPE=Bridge
BOOTPROTO=dhcp
ONBOOT=yes

# /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=none
BRIDGE=br0
ONBOOT=yes

# 重启网络
sudo systemctl restart network
```

**在虚拟机中使用桥接网络**:

```bash
virt-install \
    --network bridge=br0 \
    ...
```

### 端口转发

```bash
# QEMU 用户网络端口转发
qemu-system-x86_64 \
    -net nic \
    -net user,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80 \
    ...
```

## 💾 磁盘管理

### 磁盘镜像操作

```bash
# 创建磁盘镜像
qemu-img create -f qcow2 disk.qcow2 10G

# 转换镜像格式
qemu-img convert -f raw -O qcow2 input.raw output.qcow2

# 调整镜像大小
qemu-img resize disk.qcow2 +10G

# 压缩镜像
qemu-img convert -c -O qcow2 input.qcow2 output.qcow2

# 查看镜像信息
qemu-img info disk.qcow2

# 检查镜像完整性
qemu-img check disk.qcow2
```

### 挂载和卸载磁盘

```bash
# 挂载 qcow2 镜像
sudo modprobe nbd max_part=8
sudo qemu-nbd --connect=/dev/nbd0 disk.qcow2
sudo mount /dev/nbd0p1 /mnt

# 卸载
sudo umount /mnt
sudo qemu-nbd --disconnect /dev/nbd0
```

## 🔧 高级配置

### CPU 配置

```bash
# 指定 CPU 型号
-cpu Skylake-Client

# 使用宿主机 CPU 特性
-cpu host

# 配置 CPU 拓扑
-smp 4,cores=2,threads=2,sockets=1
```

### 内存配置

```bash
# 静态分配内存
-m 4096

# 动态内存（需要 balloon 驱动）
-m 4096 -device virtio-balloon-pci
```

### GPU 透传

```bash
# 查找 GPU 设备
lspci | grep VGA

# 透传 PCI 设备
-device vfio-pci,host=01:00.0
```

### 性能优化

```bash
# 使用 virtio 设备驱动
-drive file=disk.qcow2,if=virtio
-net nic,model=virtio
-device virtio-scsi-pci,id=scsi0
-device scsi-hd,drive=hd0,bus=scsi0.0

# 启用 CPU 固定
virsh vcpupin vm-name 0 1
virsh vcpupin vm-name 1 2

# 启用大页内存
virsh edit vm-name
# 添加:
<memoryBacking>
  <hugepages/>
</memoryBacking>
```

## 📊 监控和调试

### 监控资源使用

```bash
# CPU 使用率
virsh cpu-stats vm-name

# 内存使用
virsh dommemstat vm-name

# 磁盘 I/O
virsh domblkstat vm-name vda

# 网络流量
virsh domifstat vm-name vnet0
```

### QEMU Monitor

```bash
# 进入 QEMU monitor
Ctrl+Alt+2  # 在 QEMU 图形界面中

# 或启动时指定
qemu-system-x86_64 -monitor stdio ...

# 常用 monitor 命令
info status           # 查看状态
info block            # 查看块设备
info network          # 查看网络
savevm snapshot1      # 创建快照
loadvm snapshot1      # 加载快照
```

## 💡 最佳实践

1. **使用 KVM 加速**: 在支持的硬件上始终使用 `-enable-kvm`
2. **virtio 驱动**: 优先使用 virtio 设备获得最佳性能
3. **qcow2 格式**: 使用 qcow2 格式支持快照和精简配置
4. **定期备份**: 定期备份虚拟机磁盘镜像
5. **资源监控**: 监控虚拟机资源使用情况
6. **安全隔离**: 为不同用途的虚拟机使用不同的网络

## 🔗 参考资源

- [QEMU 官方文档](https://www.qemu.org/documentation/)
- [KVM 官方网站](https://www.linux-kvm.org/)
- [libvirt 文档](https://libvirt.org/docs.html)
- [Red Hat 虚拟化指南](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_virtualization/)

## 📝 相关文档

!!! note "计划中的文档"
    以下文档正在编写中，敬请期待：
    
    - 在 CentOS 8 上创建虚拟机
    - 在 Linux 上安装 QEMU
    - 在 macOS 上安装 QEMU

---

!!! tip "提示"
    本文档持续更新中，更多高级特性和使用案例将陆续添加。
