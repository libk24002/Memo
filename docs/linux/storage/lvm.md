# LVM 高级特性

!!! warning "高级主题"
    本文档涉及 LVM 的高级特性，建议先阅读 [LVM 基础](lvm/README.md) 后再学习本部分内容。

## 🔄 LVM RAID 功能

LVM 从 2.02.98 版本开始内置 RAID 支持，可以在逻辑卷层面实现 RAID 功能。

### 创建 RAID 逻辑卷

```bash
# RAID 0（条带化）
lvcreate --type raid0 -L 10G -i 2 -n lv_raid0 vg_data /dev/sdb1 /dev/sdc1

# RAID 1（镜像）
lvcreate --type raid1 -m 1 -L 10G -n lv_raid1 vg_data /dev/sdb1 /dev/sdc1

# RAID 5
lvcreate --type raid5 -i 3 -L 10G -n lv_raid5 vg_data \
    /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1

# RAID 6
lvcreate --type raid6 -i 3 -L 10G -n lv_raid6 vg_data \
    /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdf1

# RAID 10
lvcreate --type raid10 -m 1 -i 2 -L 10G -n lv_raid10 vg_data \
    /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1
```

### RAID 逻辑卷管理

```bash
# 查看 RAID 状态
lvs -a -o +devices,seg_pe_ranges,segtype

# 详细 RAID 信息
lvdisplay -m /dev/vg_data/lv_raid1

# 转换 RAID 级别（RAID 1 → RAID 5）
lvconvert --type raid5 /dev/vg_data/lv_raid1

# 修复损坏的 RAID
lvconvert --repair /dev/vg_data/lv_raid1
```

## 📊 LVM 缓存（Cache）

LVM 缓存可以使用快速存储（SSD）作为慢速存储（HDD）的缓存层。

### 创建缓存卷

```bash
# 假设 /dev/ssd1 是 SSD，/dev/hdd1 是 HDD

# 1. 创建主逻辑卷（使用 HDD）
lvcreate -L 100G -n lv_data vg_data /dev/hdd1

# 2. 创建缓存池（使用 SSD）
lvcreate --type cache-pool -L 10G -n cache_pool vg_data /dev/ssd1

# 3. 将缓存池附加到逻辑卷
lvconvert --type cache --cachepool cache_pool vg_data/lv_data

# 查看缓存状态
lvs -a -o +cache_mode,cache_policy,cache_settings
```

### 缓存策略

```bash
# 设置缓存模式
# writethrough: 写穿透模式（安全但慢）
# writeback: 写回模式（快但风险高）
lvchange --cachemode writethrough vg_data/lv_data
lvchange --cachemode writeback vg_data/lv_data

# 分离缓存
lvconvert --uncache vg_data/lv_data
```

## 🔐 LVM 加密

使用 LUKS（Linux Unified Key Setup）对 LVM 进行加密。

### 创建加密的逻辑卷

**方法一：先加密分区再创建 LVM**

```bash
# 1. 加密物理分区
cryptsetup luksFormat /dev/sdb1

# 2. 打开加密分区
cryptsetup open /dev/sdb1 encrypted_disk

# 3. 在加密分区上创建 PV
pvcreate /dev/mapper/encrypted_disk

# 4. 创建 VG 和 LV
vgcreate vg_secure /dev/mapper/encrypted_disk
lvcreate -L 10G -n lv_secure vg_secure
```

**方法二：先创建 LVM 再加密逻辑卷**

```bash
# 1. 创建逻辑卷
lvcreate -L 10G -n lv_data vg_data

# 2. 加密逻辑卷
cryptsetup luksFormat /dev/vg_data/lv_data

# 3. 打开加密逻辑卷
cryptsetup open /dev/vg_data/lv_data lv_data_crypt

# 4. 格式化并挂载
mkfs.ext4 /dev/mapper/lv_data_crypt
mount /dev/mapper/lv_data_crypt /mnt/secure
```

### 自动挂载加密卷

编辑 `/etc/crypttab`:

```bash
lv_data_crypt /dev/vg_data/lv_data none luks
```

编辑 `/etc/fstab`:

```bash
/dev/mapper/lv_data_crypt /mnt/secure ext4 defaults 0 2
```

## 🎯 LVM Thin Provisioning（精简配置）

精简配置允许过量分配存储空间，只在实际写入数据时才占用物理空间。

### 创建精简卷

```bash
# 1. 创建精简池
lvcreate -L 50G --thinpool thin_pool vg_data

# 2. 创建精简卷（虚拟大小可以超过池大小）
lvcreate -V 100G --thin vg_data/thin_pool -n thin_vol1
lvcreate -V 100G --thin vg_data/thin_pool -n thin_vol2
lvcreate -V 100G --thin vg_data/thin_pool -n thin_vol3

# 查看精简池状态
lvs -a -o +devices,data_percent,metadata_percent
```

### 精简卷快照

精简卷的快照非常高效，因为它们共享相同的数据块。

```bash
# 创建精简快照
lvcreate -s vg_data/thin_vol1 -n thin_vol1_snap

# 精简快照几乎不占用额外空间
lvs -o +data_percent
```

### 自动扩展精简池

编辑 `/etc/lvm/lvm.conf`:

```conf
activation {
    thin_pool_autoextend_threshold = 70
    thin_pool_autoextend_percent = 20
}
```

## 🔄 LVM 迁移

### 在线迁移数据

```bash
# 将数据从一个 PV 迁移到另一个 PV
pvmove /dev/sdb1 /dev/sdc1

# 迁移特定 LV
pvmove -n lv_data /dev/sdb1 /dev/sdc1

# 查看迁移进度
pvmove -i 10  # 每 10 秒更新一次进度
```

### 卷组重命名和迁移

```bash
# 重命名卷组
vgrename old_vg_name new_vg_name

# 导出卷组（用于迁移到其他系统）
vgchange -an vg_data
vgexport vg_data

# 在目标系统上导入
vgimport vg_data
vgchange -ay vg_data
```

## 📈 LVM 性能调优

### 条带化（Striping）

将数据分布在多个物理卷上以提高性能。

```bash
# 创建条带化逻辑卷
# -i 指定条带数量
# -I 指定条带大小（默认 64KB）
lvcreate -L 10G -i 3 -I 128 -n lv_striped vg_data \
    /dev/sdb1 /dev/sdc1 /dev/sdd1
```

### 读写缓存优化

```bash
# 设置预读取大小
lvchange --readahead 1024 vg_data/lv_data

# 自动设置
lvchange --readahead auto vg_data/lv_data
```

## 🔍 LVM 监控和诊断

### 监控 LVM 状态

```bash
# 监控 I/O 统计
lvs -o +lv_read_ahead,lv_kernel_read_ahead

# 检查 LVM 元数据
vgck vg_data

# 备份 LVM 元数据
vgcfgbackup vg_data

# 恢复 LVM 元数据
vgcfgrestore vg_data
```

### 问题诊断

```bash
# 扫描所有块设备
pvscan --cache

# 激活所有卷组
vgchange -ay

# 修复元数据
vgck --updatemetadata vg_data

# 强制删除损坏的 LV
lvremove -f /dev/vg_data/broken_lv
```

## 🛠️ LVM 标签和过滤

### 设备标签

```bash
# 为 PV 添加标签
pvchange --addtag production /dev/sdb1
pvchange --addtag ssd /dev/sdc1

# 创建 LV 时使用标签
lvcreate -L 10G -n lv_prod vg_data @production

# 查看标签
pvs -o +tags
```

### 设备过滤

编辑 `/etc/lvm/lvm.conf`:

```conf
devices {
    # 只扫描特定设备
    filter = [ "a|/dev/sd[bc]|", "r|.*|" ]
    
    # 排除特定设备
    filter = [ "r|/dev/sda|", "a|.*|" ]
}
```

## 📋 LVM 配置文件

### 主要配置项

`/etc/lvm/lvm.conf` 重要配置：

```conf
devices {
    dir = "/dev"
    scan = [ "/dev" ]
    filter = [ "a|.*|" ]
}

allocation {
    thin_pool_metadata_require_separate_pvs = 0
    cache_pool_metadata_require_separate_pvs = 0
}

backup {
    backup = 1
    backup_dir = "/etc/lvm/backup"
    archive = 1
    archive_dir = "/etc/lvm/archive"
}

log {
    verbose = 0
    level = 0
    file = "/var/log/lvm/lvm.log"
}
```

## 🚨 故障恢复

### 恢复损坏的元数据

```bash
# 1. 查看备份
ls -l /etc/lvm/backup/
ls -l /etc/lvm/archive/

# 2. 恢复元数据
vgcfgrestore -f /etc/lvm/backup/vg_data vg_data

# 3. 激活卷组
vgchange -ay vg_data
```

### 强制激活

```bash
# 在集群环境中强制激活
vgchange -aey vg_data

# 跳过损坏的 LV
lvchange -aey --partial vg_data/lv_data
```

## 💡 高级最佳实践

1. **分层存储**: 使用 SSD 作为缓存，HDD 作为数据存储
2. **精简配置**: 在虚拟化环境中使用精简卷节省空间
3. **定期备份**: 自动备份 LVM 元数据
4. **监控告警**: 监控精简池使用率，避免空间耗尽
5. **性能优化**: 合理使用条带化提升 I/O 性能
6. **加密保护**: 对敏感数据使用 LUKS 加密

## 🔗 相关资源

- [LVM 基础教程](lvm/README.md)
- [Red Hat LVM Administrator Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_logical_volumes/)
- [LVM2 Resource Page](https://sourceware.org/lvm2/)
- [Arch Wiki - LVM](https://wiki.archlinux.org/title/LVM)

---

!!! tip "提示"
    LVM 高级特性功能强大，但配置错误可能导致数据丢失。建议在测试环境中充分验证后再应用于生产环境。
