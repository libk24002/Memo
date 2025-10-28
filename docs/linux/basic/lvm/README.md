# LVM(logical volume manager)

## Main usage
1. physical to logical abstraction
    * you can manage multiple disks as one logical volume
    * you can split one disk into multiple logical volumes
2. dynamic volume resizing
    * resizing logical disks
3. add more physical disks or move old physical disks for needs
    * in combination with hot swapping, you can add or replace disks without stopping the service

## Conceptions
![lvm.svg from wikipedia](resources/lvm.svg ':size=25%')
1. PVs: physical volumes
    * can be hard disks or partitions
    * LVM treats each PV as a sequences of PEs(physical extends)
2. PEs: physical extends
    * PEs have a uniform size, which is the minimal storage size for LVM
3. LEs: logical extends
    * usually mapping to PEs as one to one relationship
4. VG: volume group
    * each VG is a pool of LE
    * consequently, VG consists of multiple PVs
5. LVs: logical volumes
    * LEs can be concatenated together into virtual disk partitions called LVs
    * LVs can be used as raw block devices, which is supported by Linux kernel
    * in result, we can use LVs as file systems, swap and so on

## Practise
* you need to know basic [conceptions](#conceptions)
* but only PV, PE, VG and LV appear in commands
* a machine according to [install centos 8](../../install/centos/8/README.md)

### Purpose
* check volume structures after default centos 8 installation
* resize LV
    + ext filesystem
    + xfs filesystem
    + swap
* resize PV
    + will affect VG size
    + won't affect disk partition size
* create PV? VG?

### Do it
1. Check volume structures
    * use `fdisk -l` to check disks
        + ![fdisk -l](resources/lvm_1.png ':size=35%')
        + we have a disk `/dev/sda` whose storage size is 75.2G
            * This disk has been made into a logical volume group named `centos`
        + we have a disk `/dev/sdb` whose storage size is 53.7G
    * use `df -h` to check mount points of partitions
        + ![df -h](resources/lvm_2.png ':size=35%')
        * `/dev/sda2` is mounted to `/boot`
        * `/dev/mapper/cetos-root` is mounted to `/`
    * use `vgs` to list VGs
    * use `pvs` to list VGs
    * use `lvs` to list VGs
    * demos for `vgs`, `pvs` and `lvs`
        + ![img.png](resources/lvm_3.png ':size=35%')
        + we have one VG named `centos`
        + we have one PV created by the physical disk partition device `/dev/sda3`
        + we have two LVs named `root`
    * use `lsblk -f` to check filesystems
        + ![img.png](resources/lvm_4.png ':size=35%')
        + disk `sda` is partitioned to `sda1` `sda2` and `sd3`
        + the filesystem type of partition `sda2` is `xfs`
        + partition `3da2`, which is split into one LVs(`centos-root`), is `LVM2_member`
        + the filesystem type of `centos-root` is `xfs`
2. Create PVs, VGs and LVs
    * use `fdisk -l` we will see another disk named `/dev/sdb`
      + ![fdisk -l](resources/lvm_1.png ':size=35%')
    * use `fdisk /dev/sdb` to partition the disk named `/dev/sdb`
        + ```text
          [root@1908 ~]# fdisk /dev/sdb 
          Welcome to fdisk (util-linux 2.23.2).
          
          Changes will remain in memory only, until you decide to write them.
          Be careful before using the write command.
          
          Device does not contain a recognized partition table
          Building a new DOS disklabel with disk identifier 0xa3216e60.
          
          Command (m for help): n
          Partition type:
          p   primary (0 primary, 0 extended, 4 free)
          e   extended
          Select (default p): p
          Partition number (1-4, default 1):
          First sector (2048-104857599, default 2048):
          Using default value 2048
          Last sector, +sectors or +size{K,M,G} (2048-104857599, default 104857599): +10G
          Partition 1 of type Linux and of size 10 GiB is set
          
          Command (m for help): n
          Partition type:
          p   primary (1 primary, 0 extended, 3 free)
          e   extended
          Select (default p): p
          Partition number (2-4, default 2):
          First sector (20973568-104857599, default 20973568):
          Using default value 20973568
          Last sector, +sectors or +size{K,M,G} (20973568-104857599, default 104857599): +20G
          Partition 2 of type Linux and of size 20 GiB is set
          
          Command (m for help): n
          Partition type:
          p   primary (2 primary, 0 extended, 2 free)
          e   extended
          Select (default p): p
          Partition number (3,4, default 3):
          First sector (62916608-104857599, default 62916608):
          Using default value 62916608
          Last sector, +sectors or +size{K,M,G} (62916608-104857599, default 104857599):
          Using default value 104857599
          Partition 3 of type Linux and of size 20 GiB is set
          
          Command (m for help): w
          The partition table has been altered!
          
          Calling ioctl() to re-read partition table.
          Syncing disks.
          ```
        + disk `/dev/sdb` is partitioned into `/dev/sdb1`, `/dev/sdb2` and `/dev/sdb3`
           * storage size of `/dev/sdb1` is 10G
           * storage size of `/dev/sdb2` is 20G
           * storage size of `/dev/sdb3` is 20G
    * use `pvcreate` to create PVs
        + ![pvcreate](resources/lvm_5.png ':size=30%')
        + three PVs were created: `/dev/sdb1`, `/dev/sdb1`, `/dev/sdb1`
        + each PV bind with a disk partition
    * use `vgcreate` to create VGs
        + ![vgcreate](resources/lvm_6.png ':size=30%')
        + a VG named `vg-test` was created
        + `vg-test` consists of two PVs(`/dev/sdb1` and `/dev/sdb2`)
        + `/dev/sdb3` was added into VG named `vg-test` by `vgextend`
        + `/dev/sdb2` was removed from VG named `vg-test` by `vgreduce`
        + finally, `/dev/sdb2` was added into VG named `vg-test` by `vgextend`
    * use `lvcreate` to create LVs
        + ![lvcreate](resources/lvm_7.png ':size=30%')
        + we create a LV named `small`, whose storage size is 5G
        + we create a LV named `medium`, whose storage size is 10G
        + we create a LV named `large`, whose storage size is 24G
        + LV named `small` is mapped to `/dev/mapper/vg--test-small`
        + LV named `medium` is mapped to `/dev/mapper/vg--test-medium`
        + LV named `large` is mapped to `/dev/mapper/vg--test-large`
    * use `mkfs.xfs` to make `xfs` filesystem for `/dev/mapper/vg--test-small` and `/dev/mapper/vg--test-large`
        + ```shell
          mkfs.xfs /dev/mapper/vg--test-small 
          mkfs.xfs /dev/mapper/vg--test-large
          ```
    * use `mkfs.ext4` to make `xfs` filesystem for `/dev/mapper/vg--test-medium`
        + ```shell
          mkfs.ext4 /dev/mapper/vg--test-medium
          ```
    * filesystems can be mounted into any path
        + ![filesystems](resources/lvm_8.png ':size=30%')
3. resize LV of xfs filesystem
    * xfs filesystem itself not support resize
    * resize LV of xfs filesystem by re-create it
        + ![img_4.png](resources/lvm_9.png ':size=30%')
        + `/dev/mapper/vg--test-large` resized from 24G to 18G
        + **NOTE**: the data will be loss, you should backup the data and restore it back in production environment
5. resize LV of ext4 filesystem
    * ext4 filesystem itself is resizable
    * resize `/dev/mapper/vg--test-medium`
        + ```shell
          umount /dev/mapper/vg--test-medium
          e2fsck -f /dev/mapper/vg--test-medium \
              && resize2fs /dev/mapper/vg--test-medium 5G \
              && lvreduce -L 5G /dev/mapper/vg--test-medium \
              && e2fsck /dev/mapper/vg--test-medium
          mount /dev/mapper/vg--test-medium /mnt/medium 
          ```
5. now you can image the case
    * add or remove PVs in VGs
    * then resize the filesystem online
    * or replace the hardware disks online(need `pvmove` which will be introduced another time)
