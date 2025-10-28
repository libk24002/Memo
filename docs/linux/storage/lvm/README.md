# Linux LVM (逻辑卷管理器)

!!! info "LVM 简介"
    LVM（Logical Volume Manager）是 Linux 环境中对磁盘分区进行管理的一种机制，它是建立在硬盘和分区之上的一个逻辑层，来提高磁盘分区管理的灵活性。

## 📖 LVM 基本概念

### 核心组件

- **物理卷 PV (Physical Volume)**: 物理卷就是指硬盘分区或从逻辑上与硬盘分区具有同样功能的设备（如 RAID），是 LVM 的基本存储逻辑块。
- **卷组 VG (Volume Group)**: 卷组是由一个或多个物理卷组成的存储池。
- **逻辑卷 LV (Logical Volume)**: 逻辑卷是从卷组中"切"出来的一块空间，用于创建文件系统。
- **物理区域 PE (Physical Extent)**: 每一个物理卷被划分为称为 PE 的基本单元，具有唯一编号的 PE 是可以被 LVM 寻址的最小单元。PE 的大小是可配置的，默认为 4MB。

### LVM 架构图

```
┌─────────────────────────────────────────────┐
│           文件系统 (File System)              │
├─────────────────────────────────────────────┤
│         逻辑卷 LV (Logical Volume)           │
│   /dev/vg_name/lv_root  /dev/vg_name/lv_home │
├─────────────────────────────────────────────┤
│          卷组 VG (Volume Group)              │
│              vg_name                         │
├───────────────┬─────────────────┬───────────┤
│   物理卷 PV   │    物理卷 PV    │  物理卷 PV  │
│   /dev/sda1   │    /dev/sdb1    │  /dev/sdc1 │
├───────────────┼─────────────────┼───────────┤
│  物理硬盘      │   物理硬盘      │  物理硬盘   │
│   /dev/sda    │   /dev/sdb      │  /dev/sdc  │
└───────────────┴─────────────────┴───────────┘
```

## 🚀 LVM 基本操作

### 1. 创建物理卷 (PV)

```bash
# 查看可用的分区
fdisk -l

# 创建物理卷
pvcreate /dev/sdb1
pvcreate /dev/sdc1

# 查看物理卷
pvdisplay
pvs
```

### 2. 创建卷组 (VG)

```bash
# 创建卷组（将多个 PV 加入到 VG）
vgcreate vg_data /dev/sdb1 /dev/sdc1

# 查看卷组
vgdisplay
vgs

# 扩展卷组（添加新的 PV）
vgextend vg_data /dev/sdd1
```

### 3. 创建逻辑卷 (LV)

```bash
# 创建逻辑卷（指定大小）
lvcreate -L 10G -n lv_mysql vg_data

# 创建逻辑卷（使用百分比）
lvcreate -l 100%FREE -n lv_data vg_data

# 查看逻辑卷
lvdisplay
lvs
```

### 4. 格式化和挂载

```bash
# 格式化逻辑卷
mkfs.ext4 /dev/vg_data/lv_mysql

# 创建挂载点
mkdir -p /data/mysql

# 挂载
mount /dev/vg_data/lv_mysql /data/mysql

# 查看挂载
df -h

# 设置开机自动挂载
echo '/dev/vg_data/lv_mysql /data/mysql ext4 defaults 0 0' >> /etc/fstab
```

## 📈 LVM 扩容操作

### 扩展逻辑卷

```bash
# 查看当前状态
lvs
vgs

# 扩展逻辑卷（增加 5G）
lvextend -L +5G /dev/vg_data/lv_mysql

# 或者扩展到指定大小
lvextend -L 20G /dev/vg_data/lv_mysql

# 调整文件系统大小
# 对于 ext4 文件系统
resize2fs /dev/vg_data/lv_mysql

# 对于 xfs 文件系统
xfs_growfs /data/mysql

# 验证扩容结果
df -h
```

### 一步完成扩展和调整

```bash
# -r 参数会自动调整文件系统大小
lvextend -r -L +5G /dev/vg_data/lv_mysql
```

## 📉 LVM 缩减操作

!!! warning "注意"
    缩减逻辑卷有数据丢失的风险，操作前务必备份数据！XFS 文件系统不支持缩减。

```bash
# 1. 卸载文件系统
umount /data/mysql

# 2. 检查文件系统
e2fsck -f /dev/vg_data/lv_mysql

# 3. 缩减文件系统（仅 ext4 支持）
resize2fs /dev/vg_data/lv_mysql 8G

# 4. 缩减逻辑卷
lvreduce -L 8G /dev/vg_data/lv_mysql

# 5. 重新挂载
mount /dev/vg_data/lv_mysql /data/mysql
```

## 🗑️ LVM 删除操作

```bash
# 1. 卸载逻辑卷
umount /data/mysql

# 2. 删除逻辑卷
lvremove /dev/vg_data/lv_mysql

# 3. 删除卷组（需要先删除其中所有 LV）
vgremove vg_data

# 4. 删除物理卷
pvremove /dev/sdb1
```

## 📊 LVM 快照功能

LVM 快照可以创建逻辑卷的即时副本，非常适合备份场景。

```bash
# 创建快照（分配 2G 空间）
lvcreate -L 2G -s -n lv_mysql_snap /dev/vg_data/lv_mysql

# 挂载快照进行备份
mkdir -p /backup
mount /dev/vg_data/lv_mysql_snap /backup

# 备份数据
tar -czf /tmp/mysql_backup.tar.gz /backup

# 卸载并删除快照
umount /backup
lvremove /dev/vg_data/lv_mysql_snap
```

## 🔍 常用查看命令

### 物理卷 PV

```bash
pvs         # 简要信息
pvdisplay   # 详细信息
pvscan      # 扫描所有物理卷
```

### 卷组 VG

```bash
vgs         # 简要信息
vgdisplay   # 详细信息
vgscan      # 扫描所有卷组
```

### 逻辑卷 LV

```bash
lvs         # 简要信息
lvdisplay   # 详细信息
lvscan      # 扫描所有逻辑卷
```

## 💡 最佳实践

1. **合理规划**: 在创建 LVM 前，要规划好磁盘分区和逻辑卷的大小
2. **预留空间**: 不要将卷组的空间全部分配完，预留一部分以备扩容
3. **定期备份**: 虽然 LVM 提供快照功能，但仍需定期进行完整备份
4. **监控空间**: 定期监控逻辑卷的使用情况，及时扩容
5. **谨慎缩减**: 缩减逻辑卷有风险，操作前务必备份数据

## 🔗 相关链接

- [LVM 官方文档](https://sourceware.org/lvm2/)
- [Red Hat LVM 管理指南](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_logical_volumes/index)
- [LVM 进阶用法](../lvm.md)

## 📝 常见问题

### Q: LVM 和传统分区的区别？

A: LVM 提供了更灵活的磁盘管理方式，可以动态调整分区大小，而传统分区一旦创建就很难更改。

### Q: 使用 LVM 会影响性能吗？

A: LVM 会引入很小的性能开销（通常小于 5%），但相比其带来的灵活性，这点开销是值得的。

### Q: 可以在 LVM 上使用 RAID 吗？

A: 可以，可以先创建 RAID，然后在 RAID 设备上创建 LVM，或者使用 LVM 的 RAID 功能。
