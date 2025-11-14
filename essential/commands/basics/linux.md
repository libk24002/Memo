## Command

### 下载文件(目录)
* 使用wget 下载目标目录文件
    + `-r` 遍历所有子目录
    + `-np` 不到上一层子目录去
    + `-nH` 不要将文件保存到主机名文件夹
    + `-R index.html` 不下载 index.html 文件
    + ```shell
      wget -r -np -nH -R index.html http://url/including/files/you/want/to/download/
      ```

### 求两个linux文件的交集/差集/并集
* ```shell
  sort a.txt b.txt | uniq -d    # 交集
  sort a.txt b.txt | uniq       # 并集
  sort a.txt b.txt b.txt | uniq -u  # 差集 a - b
  sort b.txt a.txt a.txt | uniq -u  # 差集 b - a
  ```

### 同步YUM仓库
* `centos 7`
    + `--downloadcomps` 下载comps.xml
    + `--download-metadata` 下载所有非默认元数据
    + ```shell
      reposync -r base --download_path /data --downloadcomps --download-metadata
      ```
* `centos 8`
    + `--downloadonly` 仅下载
    + `--download-metadata` 下载所有非默认元数据
    + `--downloadcomps` 下载comps.xml
    + ```shell
      reposync --repo base --destdir /data  --downloadonly --download-metadata --downloadcomps
      ```

### 查询系统信息
* ```shell
  arch      #显示机器的处理器架构(1)
  uname -m  #显示机器的处理器架构(2)
  uname -r  #显示正在使用的内核版本
  dmidecode -q          #显示硬件系统部件 - (SMBIOS / DMI)
  hdparm -i /dev/hda    #罗列一个磁盘的架构特性
  hdparm -tT /dev/sda   #在磁盘上执行测试性读取操作
  cat /proc/cpuinfo     #显示CPU info的信息
  cat /proc/interrupts  #显示中断
  cat /proc/meminfo     #校验内存使用
  cat /proc/swaps       #显示哪些swap被使用
  cat /proc/version     #显示内核的版本
  cat /proc/net/dev     #显示网络适配器及统计
  cat /proc/mounts      #显示已加载的文件系统
  lspci -tv   #罗列PCI设备
  lsusb -tv   #显示USB设备
  ```

### Date显示系统日期
* ```shell
  cal 2007              #显示2007年的日历表
  date 041217002007.00   #设置日期和时间 - 月日时分年.秒
  clock -w              #将时间修改保存到 BIOS
  ```

### 关机【系统关机、重启以及登录】
* ```shell
  shutdown -h now    #关闭系统(1)
  init 0            #关闭系统(2)
  telinit 0         #关闭系统(3)
  shutdown -h hours:minutes &   #按预定时间关闭系统
  shutdown -c       #取消按预定时间关闭系统
  shutdown -r now   #重启(1)
  reboot   #重启(2)
  logout   #注销
  ```

### JEMMY
* ```shell
  touch -t 0712250000 file1   #修改一个文件或目录的时间戳 - (YYMMDDhhmm)
  iconv -l   #列出已知的编码
  iconv -f fromEncoding -t toEncoding inputFile
  # curl -s http://www.google.com.hk/ | iconv -f big5 -t gbk # 将Google香港的Big5编码转换成GBK编码
  ```

### 文件搜索
* ```shell
  find . -maxdepth 1 -name *.jpg -print -exec convert "{}" -resize 80x60 "thumbs/{}" \; batch resize files in the current directory and send them to a thumbnails directory (requires convert from Imagemagick)
  find / -name file1     #从 '/' 开始进入根文件系统搜索文件和目录
  find / -user user1     #搜索属于用户 'user1' 的文件和目录
  find /home/user1 -name \*.bin        #在目录 '/ home/user1' 中搜索带有'.bin' 结尾的文件
  find /usr/bin -type f -atime +100    #搜索在过去100天内未被使用过的执行文件
  find /usr/bin -type f -mtime -10     #搜索在10天内被创建或者修改过的文件
  find / -name \*.rpm -exec chmod 755 '{}' \;      #搜索以 '.rpm' 结尾的文件并定义其权限
  find / -xdev -name \*.rpm        #搜索以 '.rpm' 结尾的文件，忽略光驱、捷盘等可移动设备
  locate \*.ps       #寻找以 '.ps' 结尾的文件 - 先运行 'updatedb' 命令
  whereis halt       #显示一个二进制文件、源码或man的位置
  which halt         #显示一个二进制文件或可执行文件的完整路径
  ```

### 挂载一个文件系统
* ```shell
  fuser -km /mnt/hda2         #当设备繁忙时强制卸载
  umount -n /mnt/hda2         #运行卸载操作而不写入 /etc/mtab 文件- 当文件为只读或当磁盘写满时非常有用
  mount -o loop file.iso /mnt/cdrom    #挂载一个文件或ISO镜像文件
  mount -t vfat /dev/hda5 /mnt/hda5    #挂载一个Windows FAT32文件系统
  mount /dev/sda1 /mnt/usbdisk         #挂载一个usb 捷盘或闪存设备
  mount -t smbfs -o username=user,password=pass //WinClient/share /mnt/share   #挂载一个windows网络共享
  ```

### 磁盘空间
* ```shell
  ls -lSr |more    #以尺寸大小排列文件和目录
  du -sk * | sort -rn     #以容量大小为依据依次显示文件和目录的大小
  rpm -q -a --qf '%10{SIZE}t%{NAME}n' | sort -k1,1n    #以大小为依据依次显示已安装的rpm包所使用的空间 (fedora, redhat类系统)
  dpkg-query -W -f='${Installed-Size;10}t${Package}n' | sort -k1,1n    #以大小为依据显示已安装的deb包所使用的空间 (ubuntu, debian类系统)
  ```

### 用户和群组
* ```shell
  groupmod -n new_group_name old_group_name   #重命名一个用户组
  useradd -c "Name Surname " -g admin -d /home/user1 -s /bin/bash user1     #创建一个属于 "admin" 用户组的用户
  userdel -r user1   #删除一个用户 ( '-r' 排除主目录)
  usermod -c "User FTP" -g system -d /ftp/user1 -s /bin/nologin user1   #修改用户属性

  chage -E 2005-12-31 user1    #设置用户口令的失效期限
  pwck     #检查 '/etc/passwd' 的文件格式和语法修正以及存在的用户
  grpck    #检查 '/etc/passwd' 的文件格式和语法修正以及存在的群组
  newgrp group_name     #登陆进一个新的群组以改变新创建文件的预设群组
  ```

### 文件的限权
* ```shell
  ls -lh    #显示权限
  ls /tmp | pr -T5 -W$COLUMNS   #将终端划分成5栏显示
  chgrp group1 file1          #改变文件的群组
  find / -perm -u+s           #罗列一个系统中所有使用了SUID控制的文件
  chmod u+s /bin/file1        #设置一个二进制文件的 SUID 位 - 运行该文件的用户也被赋予和所有者同样的权限
  chmod u-s /bin/file1        #禁用一个二进制文件的 SUID位
  chmod g+s /home/public      #设置一个目录的SGID 位 - 类似SUID ，不过这是针对目录的
  chmod g-s /home/public      #禁用一个目录的 SGID 位
  chmod o+t /home/public      #设置一个文件的 STIKY 位 - 只允许合法所有人删除文件
  chmod o-t /home/public      #禁用一个目录的 STIKY 位
  ```

### 文件的特殊属性
* ```shell
  chattr +a file1   #只允许以追加方式读写文件
  chattr +c file1   #允许这个文件能被内核自动压缩/解压
  chattr +d file1   #在进行文件系统备份时，dump程序将忽略这个文件
  chattr +i file1   #设置成不可变的文件，不能被删除、修改、重命名或者链接
  chattr +s file1   #允许一个文件被安全地删除
  chattr +S file1   #一旦应用程序对这个文件执行了写操作，使系统立刻把修改的结果写到磁盘
  chattr +u file1   #若文件被删除，系统会允许你在以后恢复这个被删除的文件
  lsattr           #显示特殊的属性
  ```

### 打包和压缩文件
* ```shell
  bunzip2 file1.bz2   #解压一个叫做 'file1.bz2'的文件
  bzip2 file1         #压缩一个叫做 'file1' 的文件
  gunzip file1.gz     #解压一个叫做 'file1.gz'的文件
  gzip file1          #压缩一个叫做 'file1'的文件
  gzip -9 file1       #最大程度压缩

  rar a file1.rar test_file          #创建一个叫做 'file1.rar' 的包
  rar a file1.rar file1 file2 dir1   #同时压缩 'file1', 'file2' 以及目录 'dir1'
  rar x file1.rar     #解压rar包
  unrar x file1.rar   #解压rar包

  tar -cvf archive.tar file1   #创建一个非压缩的 tarball
  tar -cvf archive.tar file1 file2 dir1  #创建一个包含了 'file1', 'file2' 以及 'dir1'的档案文件
  tar -tf archive.tar    #显示一个包中的内容
  tar -xvf archive.tar   #释放一个包
  tar -xvf archive.tar -C /tmp     #将压缩包释放到 /tmp目录下
  tar -cvfj archive.tar.bz2 dir1   #创建一个bzip2格式的压缩包
  tar -jxvf archive.tar.bz2        #解压一个bzip2格式的压缩包
  tar -cvfz archive.tar.gz dir1    #创建一个gzip格式的压缩包
  tar -zxvf archive.tar.gz         #解压一个gzip格式的压缩包

  zip file1.zip file1    #创建一个zip格式的压缩包
  zip -r file1.zip file1 file2 dir1    #将几个文件和目录同时压缩成一个zip格式的压缩包
  unzip file1.zip    #解压一个zip格式压缩包
  ```

### RPM包—（Fedore，Redhat及类似系统）
* ```shell
  rpm -ivh package.rpm    #安装一个rpm包
  rpm -ivh --nodeeps package.rpm   #安装一个rpm包而忽略依赖关系警告
  rpm -U package.rpm        #更新一个rpm包但不改变其配置文件
  rpm -F package.rpm        #更新一个确定已经安装的rpm包
  rpm -e package_name.rpm   #删除一个rpm包
  rpm -qa      #显示系统中所有已经安装的rpm包
  rpm -qa | grep httpd    #显示所有名称中包含 "httpd" 字样的rpm包
  rpm -qi package_name    #获取一个已安装包的特殊信息
  rpm -qg "System Environment/Daemons"     #显示一个组件的rpm包
  rpm -ql package_name       #显示一个已经安装的rpm包提供的文件列表
  rpm -qc package_name       #显示一个已经安装的rpm包提供的配置文件列表
  rpm -q package_name --whatrequires     #显示与一个rpm包存在依赖关系的列表
  rpm -q package_name --whatprovides    #显示一个rpm包所占的体积
  rpm -q package_name --scripts         #显示在安装/删除期间所执行的脚本l
  rpm -q package_name --changelog       #显示一个rpm包的修改历史
  rpm -qf /etc/httpd/conf/httpd.conf    #确认所给的文件由哪个rpm包所提供
  rpm -qp package.rpm -l    #显示由一个尚未安装的rpm包提供的文件列表
  rpm --import /media/cdrom/RPM-GPG-KEY    #导入公钥数字证书
  rpm --checksig package.rpm      #确认一个rpm包的完整性
  rpm -qa gpg-pubkey      #确认已安装的所有rpm包的完整性
  rpm -V package_name     #检查文件尺寸、 许可、类型、所有者、群组、MD5检查以及最后修改时间
  rpm -Va                 #检查系统中所有已安装的rpm包- 小心使用
  rpm -Vp package.rpm     #确认一个rpm包还未安装
  rpm2cpio package.rpm | cpio --extract --make-directories *bin*   #从一个rpm包运行可执行文件
  rpm -ivh /usr/src/redhat/RPMS/`arch`/package.rpm    #从一个rpm源码安装一个构建好的包
  rpmbuild --rebuild package_name.src.rpm       #从一个rpm源码构建一个 rpm 包
  ```

### YUM软件包升级器—(Fedora,RedHat及类似系统）
* ```shell
  yum install package_name             #下载并安装一个rpm包
  yum localinstall package_name.rpm    #将安装一个rpm包，使用你自己的软件仓库为你解决所有依赖关系
  yum update package_name.rpm    #更新当前系统中所有安装的rpm包
  yum update package_name        #更新一个rpm包
  yum remove package_name        #删除一个rpm包
  yum list                   #列出当前系统中安装的所有包
  yum search package_name     #在rpm仓库中搜寻软件包
  yum clean packages          #清理rpm缓存删除下载的包
  yum clean headers           #删除所有头文件
  yum clean all                #删除所有缓存的包和头文件
  ```

## DEB包（Debian，Ubuntu以及类似系统）
* ```shell
  dpkg -i package.deb     #安装/更新一个 deb 包
  dpkg -r package_name    #从系统删除一个 deb 包
  dpkg -l                 #显示系统中所有已经安装的 deb 包
  dpkg -l | grep httpd    #显示所有名称中包含 "httpd" 字样的deb包
  dpkg -s package_name    #获得已经安装在系统中一个特殊包的信息
  dpkg -L package_name    #显示系统中已经安装的一个deb包所提供的文件列表
  dpkg --contents package.deb    #显示尚未安装的一个包所提供的文件列表
  dpkg -S /bin/ping              #确认所给的文件由哪个deb包提供
  ```

### APT软件工具（Debian，Ubuntu以及类似系统）
* ```shell
  apt-get install package_name      #安装/更新一个 deb 包
  apt-cdrom install package_name    #从光盘安装/更新一个 deb 包
  apt-get update      #升级列表中的软件包
  apt-get upgrade     #升级所有已安装的软件
  apt-get remove package_name     #从系统删除一个deb包
  apt-get check     #确认依赖的软件仓库正确
  apt-get clean     #从下载的软件包中清理缓存
  apt-cache search searched-package    #返回包含所要搜索字符串的软件包名称
  ```

### 文本处理
* ```shell
  grep Aug /var/log/messages     #在文件 '/var/log/messages'中查找关键词"Aug"
  grep ^Aug /var/log/messages    #在文件 '/var/log/messages'中查找以"Aug"开始的词汇
  grep [0-9] /var/log/messages   #选择 '/var/log/messages' 文件中所有包含数字的行
  grep Aug -R /var/log/*         #在目录 '/var/log' 及随后的目录中搜索字符串"Aug"

  sed 's/stringa1/stringa2/g' example.txt
  #将example.txt文件中的 "string1" 替换成 "string2"
  sed '/^$/d' example.txt           #从example.txt文件中删除所有空白行
  sed '/ *#/d; /^$/d' example.txt   #从example.txt文件中删除所有注释和空白行
  echo 'esempio' | tr '[:lower:]' '[:upper:]'    #合并上下单元格内容
  sed -e '1d' result.txt          #从文件example.txt 中排除第一行
  sed -n '/stringa1/p'            #查看只包含词汇 "string1"的行
  sed -e 's/ *$//' example.txt    #删除每一行最后的空白字符
  sed -e 's/stringa1//g' example.txt
  #从文档中只删除词汇 "string1" 并保留剩余全部
  sed -n '1,5p;5q' example.txt     #查看从第一行到第5行内容
  sed -n '5p;5q' example.txt       #查看第5行
  sed -e 's/00*/0/g' example.txt   #用单个零替换多个零

  cat -n file1       #标示文件的行数
  cat example.txt | awk 'NR%2==1'      #删除example.txt文件中的所有偶数行
  echo a b c | awk '{print $1}'        #查看一行第一栏
  echo a b c | awk '{print $1,$3}'     #查看一行的第一和第三栏
  paste file1 file2           #合并两个文件或两栏的内容
  paste -d '+' file1 file2    #合并两个文件或两栏的内容，中间用"+"区分

  comm -1 file1 file2    #比较两个文件的内容只删除 'file1' 所包含的内容
  comm -2 file1 file2    #比较两个文件的内容只删除 'file2' 所包含的内容
  comm -3 file1 file2    #比较两个文件的内容只删除两个文件共有的部分
  ```

### 字符设置和文件格式转换
* ```shell
  dos2unix filedos.txt fileunix.txt      #将一个文本文件的格式从MSDOS转换成UNIX
  unix2dos fileunix.txt filedos.txt      #将一个文本文件的格式从UNIX转换成MSDOS
  recode ..HTML < page.txt > page.html   #将一个文本文件转换成html
  recode -l | more                       #显示所有允许的转换格式
  ```

### 文件系统分析
* ```shell
  badblocks -v /dev/hda1    #检查磁盘hda1上的坏磁块
  fsck /dev/hda1            #修复/检查hda1磁盘上linux文件系统的完整性
  fsck.ext2 /dev/hda1       #修复/检查hda1磁盘上ext2文件系统的完整性
  e2fsck /dev/hda1          #修复/检查hda1磁盘上ext2文件系统的完整性
  e2fsck -j /dev/hda1       #修复/检查hda1磁盘上ext3文件系统的完整性
  fsck.ext3 /dev/hda1       #修复/检查hda1磁盘上ext3文件系统的完整性
  fsck.vfat /dev/hda1       #修复/检查hda1磁盘上fat文件系统的完整性
  fsck.msdos /dev/hda1      #修复/检查hda1磁盘上dos文件系统的完整性
  dosfsck /dev/hda1         #修复/检查hda1磁盘上dos文件系统的完整性
  ```

### 备份
* ```shell
  dump -0aj -f /tmp/home0.bak /home    #制作一个 '/home' 目录的完整备份
  dump -1aj -f /tmp/home0.bak /home    #制作一个 '/home' 目录的交互式备份
  restore -if /tmp/home0.bak          #还原一个交互式备份

  rsync -rogpav --delete /home /tmp    #同步两边的目录
  rsync -rogpav -e ssh --delete /home ip_address:/tmp           #通过SSH通道rsync
  rsync -az -e ssh --delete ip_addr:/home/public /home/local    #通过ssh和压缩将一个远程目录同步到本地目录
  rsync -az -e ssh --delete /home/local ip_addr:/home/public    #通过ssh和压缩将本地目录同步到远程目录

  dd bs=1M if=/dev/hda | gzip | ssh user@ip_addr 'dd of=hda.gz'
  #通过ssh在远程主机上执行一次备份本地磁盘的操作
  dd if=/dev/sda of=/tmp/file1
  #备份磁盘内容到一个文件
  tar -Puf backup.tar /home/user 执行一次对 '/home/user'
  #目录的交互式备份操作
  ( cd /tmp/local/ && tar c . ) | ssh -C user@ip_addr 'cd /home/share/ && tar x -p'
  #通过ssh在远程目录中复制一个目录内容
  ( tar c /home ) | ssh -C user@ip_addr 'cd /home/backup-home && tar x -p'
  #通过ssh在远程目录中复制一个本地目录
  tar cf - . | (cd /tmp/backup ; tar xf - )
  #本地将一个目录复制到另一个地方，保留原有权限及链接

  find /home/user1 -name '*.txt' | xargs cp -av --target-directory=/home/backup/ --parents
  #从一个目录查找并复制所有以 '.txt' 结尾的文件到另一个目录
  find /var/log -name '*.log' | tar cv --files-from=- | bzip2 > log.tar.bz2
  #查找所有以 '.log' 结尾的文件并做成一个bzip包

  dd if=/dev/hda of=/dev/fd0 bs=512 count=1
  #做一个将 MBR (Master Boot Record)内容复制到软盘的动作
  dd if=/dev/fd0 of=/dev/hda bs=512 count=1
  #从已经保存到软盘的备份中恢复MBR内容
  ```

### 网络—（以以太网和WIFI无线）
* ```shell
  ifconfig eth0    #显示一个以太网卡的配置
  ifup eth0        #启用一个 'eth0' 网络设备
  ifdown eth0      #禁用一个 'eth0' 网络设备
  ifconfig eth0 192.168.1.1 netmask 255.255.255.0     #控制IP地址
  ifconfig eth0 promisc     #设置 'eth0' 成混杂模式以嗅探数据包 (sniffing)
  dhclient eth0            #以dhcp模式启用 'eth0'

  route -n    #查看路由表
  route add -net 0/0 gw IP_Gateway    #配置默认网关
  route add -net 192.168.0.0 netmask 255.255.0.0 gw 192.168.1.1
  #配置静态路由到达网络'192.168.0.0/16'
  route del 0/0 gw IP_gateway        #删除静态路由

  hostname #查看机器名
  host www.example.com       #把一个主机名解析到一个网际地址或把一个网际地址解析到一个主机名。
  nslookup www.example.com   #用于查询DNS的记录，查看域名解析是否正常，在网络故障的时候用来诊断网络问题。
  ip link show            #查看网卡信息
  mii-tool                #用于查看、管理介质的网络接口的状态
  ethtool                 #用于查询和设置网卡配置
  netstat -tupl           #用于显示TCP/UDP的状态信息
  tcpdump tcp port 80     #显示所有http协议的流量
  ```

# shell-commands

### clean files 3 days ago
* ```shell
  find /root/database/backup/db.sql.*.gz -mtime +3 -exec rm {} \;
  ```

### ssh without affect $HOME/.ssh/known_hosts
* ```shell
  ssh -o "UserKnownHostsFile /dev/null" root@aliyun.geekcity.tech
  ```

### rsync file to remote
* ```shell
  rsync -av --delete \
      -e 'ssh -o "UserKnownHostsFile /dev/null" -p 22' \
      --exclude build/ \
      $HOME/git_projects/blog root@aliyun.geekcity.tech:/root/develop/blog
  ```

### looking for network connections
* ```shell
  ## all connections
  lsof -i -P -n
  ## specific port
  lsof -i:8083
  ```

### sync clock
* ```shell
  yum install -y chrony \
      && systemctl enable chronyd \
      && systemctl is-active chronyd \
      && chronyc sources \
      && chronyc tracking \
      && timedatectl set-timezone 'Asia/Shanghai'
  ```

### settings for screen
* ```shell
  cat > $HOME/.screenrc <<EOF
  startup_message off
  caption always "%{.bW}%-w%{.rW}%n %t%{-}%+w %=%H %Y/%m/%d "
  escape ^Jj #Instead of control-a
  shell -$SHELL
  EOF
  ```

### count code lines
* ```shell
  find . -name "*.java" | xargs cat | grep -v ^$ | wc -l
  git ls-files | while read f; do git blame --line-porcelain $f | grep '^author '; done | sort -f | uniq -ic | sort -n
  git log --author="ben.wangz" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s removed lines: %s total lines: %s\n", add, subs, loc }' -
  ```

### check sha256
* ```shell
  echo "1984c349d5d6b74279402325b6985587d1d32c01695f2946819ce25b638baa0e *ubuntu-20.04.3-preinstalled-server-armhf+raspi.img.xz" | shasum -a 256 --check
  ```

### check command existence
* ```shell
  if type firewall-cmd > /dev/null 2>&1; then
      firewall-cmd --permanent --add-port=8080/tcp;
  fi
  ```

### set hostname
* ```shell
  hostnamectl set-hostname develop
  ```

### add remote key
* ```shell
  ssh -o "UserKnownHostsFile /dev/null" root@aliyun.geekcity.tech "mkdir -p /root/.ssh && chmod 700 /root/.ssh && echo '$SOME_PUBLIC_KEY' >> /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys"
  ```

### check service logs with journalctl
* ```shell
  journalctl -u docker
  ```

### script path
* ```shell
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
  ```

### 修改密码
* ```shell
  echo '123456' | passwd --stdin conti
  ```

### 两台节点互信
* ```shell
  echo ${RSA} >> ~/.ssh/authorized_keys
  ```

### SSH 参数
* ```shell
  # 警告信息
  -o "StrictHostKeyChecking no"

  # 主机已存在
  -o "UserKnownHostsFile /dev/null"
  ```

### JAVA_HOME配置文件
* ```shell
  JAVA_HOME=/opt/jdk1.8.0_301
  JRE_HOME=$JAVA_HOME/jre
  CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib/rt.jar
  PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
  export JAVA_HOME JRE_HOME CLASSPATH PATH
  ```

### while循环文件读取
* ```shell
  ls | while read remote;
  do
  echo ${remote}
  done
  ```

# curl and wget - Complete Guide

## Overview

**curl** and **wget** are command-line tools for transferring data using various protocols (HTTP, HTTPS, FTP, etc.). While they overlap in functionality, they have different strengths:

- **curl**: More versatile, supports more protocols, better for APIs and scripting
- **wget**: Better for recursive downloads, resuming, mirroring websites

---

## curl - Comprehensive Guide

### Basic Usage

```bash
# Simple GET request
curl https://example.com

# Save output to file
curl https://example.com -o output.html
curl https://example.com --output output.html

# Save with remote filename
curl -O https://example.com/file.zip
curl --remote-name https://example.com/file.zip

# Follow redirects
curl -L https://example.com
curl --location https://example.com

# Show progress bar
curl -# https://example.com/largefile.zip -o file.zip

# Silent mode (no progress)
curl -s https://example.com
curl --silent https://example.com

# Show only response headers
curl -I https://example.com
curl --head https://example.com
```

### HTTP Methods

```bash
# GET request (default)
curl https://api.example.com/users

# POST request with data
curl -X POST https://api.example.com/users \
  -d "name=John&email=john@example.com"

# POST with JSON
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com"}'

# POST from file
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d @data.json

# PUT request
curl -X PUT https://api.example.com/users/123 \
  -H "Content-Type: application/json" \
  -d '{"name":"John Updated"}'

# PATCH request
curl -X PATCH https://api.example.com/users/123 \
  -H "Content-Type: application/json" \
  -d '{"email":"newemail@example.com"}'

# DELETE request
curl -X DELETE https://api.example.com/users/123

# OPTIONS request
curl -X OPTIONS https://api.example.com/users
```

### Headers

```bash
# Add custom header
curl -H "Authorization: Bearer TOKEN123" \
  https://api.example.com/protected

# Multiple headers
curl -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  https://api.example.com/data

# User-Agent
curl -A "MyApp/1.0" https://example.com
curl --user-agent "Mozilla/5.0" https://example.com

# Referer
curl -e https://google.com https://example.com
curl --referer https://google.com https://example.com

# Show request and response headers
curl -v https://example.com
curl --verbose https://example.com

# Show only request headers
curl -v https://example.com 2>&1 | grep '^>'

# Include response headers in output
curl -i https://example.com
curl --include https://example.com
```

### Authentication

```bash
# Basic authentication
curl -u username:password https://example.com
curl --user username:password https://example.com

# Prompt for password
curl -u username https://example.com

# Bearer token
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://api.example.com/protected

# API key in header
curl -H "X-API-Key: YOUR_API_KEY" \
  https://api.example.com/data

# Digest authentication
curl --digest -u username:password https://example.com

# OAuth2 (with token)
curl -H "Authorization: Bearer $(cat token.txt)" \
  https://api.example.com/data
```

### Cookies

```bash
# Send cookie
curl -b "session=abc123" https://example.com
curl --cookie "session=abc123" https://example.com

# Multiple cookies
curl -b "session=abc; user=john" https://example.com

# Load cookies from file
curl -b cookies.txt https://example.com

# Save cookies to file
curl -c cookies.txt https://example.com
curl --cookie-jar cookies.txt https://example.com

# Save and load cookies
curl -b cookies.txt -c cookies.txt https://example.com

# Session workflow
# 1. Login and save cookies
curl -c cookies.txt -d "user=john&pass=secret" https://example.com/login

# 2. Use session for authenticated requests
curl -b cookies.txt https://example.com/profile
curl -b cookies.txt https://example.com/data
```

### File Uploads

```bash
# Upload file (multipart/form-data)
curl -F "file=@document.pdf" https://example.com/upload
curl --form "file=@document.pdf" https://example.com/upload

# Upload with additional fields
curl -F "file=@image.jpg" \
  -F "description=My photo" \
  -F "category=personal" \
  https://example.com/upload

# Upload with custom filename
curl -F "file=@local.jpg;filename=remote.jpg" \
  https://example.com/upload

# Upload with content type
curl -F "file=@data.json;type=application/json" \
  https://example.com/upload

# Upload binary data
curl --data-binary @file.zip https://example.com/upload

# Upload from stdin
cat file.txt | curl -X POST --data-binary @- https://example.com/upload
```

### Download Operations

```bash
# Download and save
curl -O https://example.com/file.zip

# Download multiple files
curl -O https://example.com/file1.zip \
  -O https://example.com/file2.zip

# Download with custom name
curl https://example.com/file.zip -o myfile.zip

# Resume download
curl -C - -O https://example.com/largefile.zip
curl --continue-at - -O https://example.com/largefile.zip

# Download with progress bar
curl -# -O https://example.com/file.zip

# Download with rate limit (bytes/sec)
curl --limit-rate 100K -O https://example.com/file.zip
curl --limit-rate 1M -O https://example.com/file.zip

# Download with timeout
curl --max-time 300 -O https://example.com/file.zip
curl -m 300 -O https://example.com/file.zip

# Download range (partial content)
curl -r 0-999 https://example.com/file.txt
curl --range 1000-1999 https://example.com/file.txt
```

### HTTPS and SSL

```bash
# Ignore SSL certificate verification (insecure)
curl -k https://self-signed.example.com
curl --insecure https://self-signed.example.com

# Specify CA certificate
curl --cacert /path/to/ca-cert.pem https://example.com

# Use client certificate
curl --cert client.pem --key client-key.pem https://example.com

# Specify SSL/TLS version
curl --tlsv1.2 https://example.com
curl --tlsv1.3 https://example.com

# Show SSL certificate info
curl -v https://example.com 2>&1 | grep -A 10 'Server certificate'

# Test SSL connection
curl -vI https://example.com 2>&1 | grep SSL
```

### Proxy

```bash
# Use HTTP proxy
curl -x http://proxy.example.com:8080 https://example.com
curl --proxy http://proxy.example.com:8080 https://example.com

# Proxy with authentication
curl -x http://user:pass@proxy.example.com:8080 https://example.com

# SOCKS proxy
curl --socks5 127.0.0.1:1080 https://example.com

# No proxy for specific domains
curl --noproxy localhost,127.0.0.1 https://example.com

# Use system proxy settings
curl https://example.com  # Automatically uses http_proxy env var
```

### Advanced Options

```bash
# Follow redirects with max redirects
curl -L --max-redirs 5 https://example.com

# Retry on failure
curl --retry 3 https://example.com

# Retry delay
curl --retry 3 --retry-delay 5 https://example.com

# Connection timeout
curl --connect-timeout 10 https://example.com

# Maximum time for entire operation
curl --max-time 60 https://example.com

# DNS timeout
curl --dns-timeout 30 https://example.com

# Keep-Alive
curl --keepalive-time 60 https://example.com

# Interface binding
curl --interface eth0 https://example.com

# Resolve host to specific IP
curl --resolve example.com:443:93.184.216.34 https://example.com
```

### Output and Formatting

```bash
# Silent output (no progress or errors)
curl -s https://example.com

# Silent but show errors
curl -sS https://example.com

# Write output to file (URL-based filename)
curl -O https://example.com/file.zip

# Write output to custom file
curl -o myfile.html https://example.com

# Append to file
curl https://example.com >> output.txt

# Output only HTTP status code
curl -s -o /dev/null -w "%{http_code}" https://example.com

# Custom output format
curl -w "Status: %{http_code}\nTime: %{time_total}s\n" \
  -o /dev/null -s https://example.com

# JSON pretty print (with jq)
curl -s https://api.example.com/data | jq '.'

# XML pretty print (with xmllint)
curl -s https://example.com/data.xml | xmllint --format -
```

### API Testing Examples

```bash
# REST API GET
curl -s https://api.github.com/users/octocat | jq '.'

# REST API POST (create)
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30
  }' | jq '.'

# REST API PUT (update)
curl -X PUT https://api.example.com/users/123 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "name": "John Updated"
  }'

# REST API DELETE
curl -X DELETE https://api.example.com/users/123 \
  -H "Authorization: Bearer TOKEN"

# GraphQL query
curl -X POST https://api.example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ user(id: 123) { name email } }"
  }'

# Health check
curl -f https://api.example.com/health || echo "Service down"

# Webhook test
curl -X POST https://hooks.example.com/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "event": "test",
    "data": {"message": "Hello"}
  }'
```

---

## wget - Comprehensive Guide

### Basic Usage

```bash
# Download file
wget https://example.com/file.zip

# Download with custom name
wget -O myfile.zip https://example.com/file.zip
wget --output-document=myfile.zip https://example.com/file.zip

# Download to specific directory
wget -P /path/to/directory https://example.com/file.zip
wget --directory-prefix=/path/to/directory https://example.com/file.zip

# Download multiple files
wget https://example.com/file1.zip https://example.com/file2.zip

# Download from file list
wget -i urls.txt
wget --input-file=urls.txt

# Continue partial download
wget -c https://example.com/largefile.zip
wget --continue https://example.com/largefile.zip
```

### Recursive Download

```bash
# Download entire website
wget --recursive --page-requisites --convert-links \
  https://example.com

# Mirror website (commonly used options)
wget --mirror --page-requisites --convert-links \
  --no-parent https://example.com

# Short form of mirror
wget -mkEpnp https://example.com
# -m : mirror (recursive with infinite depth)
# -k : convert links for local viewing
# -E : add .html extension
# -p : get page requisites (images, CSS, etc.)
# -np : no parent (don't ascend to parent directory)

# Limit recursion depth
wget -r -l 3 https://example.com
wget --recursive --level=3 https://example.com

# Download specific file types
wget -r -A pdf,doc,docx https://example.com
wget --recursive --accept=pdf,doc,docx https://example.com

# Exclude file types
wget -r -R gif,jpg,jpeg https://example.com
wget --recursive --reject=gif,jpg,jpeg https://example.com

# Download only specific directories
wget -r -np -nH --cut-dirs=2 https://example.com/path/to/files/
```

### Speed and Limits

```bash
# Limit download speed
wget --limit-rate=200k https://example.com/file.zip
wget --limit-rate=1m https://example.com/file.zip

# Wait between downloads (seconds)
wget --wait=5 -i urls.txt

# Random wait between downloads
wget --random-wait -i urls.txt

# Limit connection timeout
wget --timeout=30 https://example.com/file.zip

# DNS timeout
wget --dns-timeout=10 https://example.com/file.zip

# Connect timeout
wget --connect-timeout=10 https://example.com/file.zip

# Read timeout
wget --read-timeout=30 https://example.com/file.zip
```

### Authentication

```bash
# HTTP basic authentication
wget --user=username --password=password https://example.com

# Prompt for password
wget --user=username --ask-password https://example.com

# FTP authentication
wget ftp://username:password@ftp.example.com/file.zip

# Use .netrc file for credentials
# Create ~/.netrc with:
# machine example.com
# login username
# password secret
chmod 600 ~/.netrc
wget https://example.com/protected/file.zip
```

### Headers and Cookies

```bash
# Add custom header
wget --header="Authorization: Bearer TOKEN" \
  https://api.example.com/data

# Multiple headers
wget --header="Header1: Value1" \
  --header="Header2: Value2" \
  https://example.com

# User agent
wget --user-agent="Mozilla/5.0" https://example.com
wget -U "MyBot/1.0" https://example.com

# Referer
wget --referer=https://google.com https://example.com

# Load cookies from file
wget --load-cookies=cookies.txt https://example.com

# Save cookies to file
wget --save-cookies=cookies.txt --keep-session-cookies \
  https://example.com
```

### HTTPS and SSL

```bash
# Ignore certificate check (insecure)
wget --no-check-certificate https://self-signed.example.com

# Specify CA certificate
wget --ca-certificate=/path/to/ca-cert.pem https://example.com

# Client certificate
wget --certificate=client-cert.pem \
  --certificate-type=PEM \
  https://example.com

# Private key for client cert
wget --certificate=client.pem \
  --private-key=key.pem \
  https://example.com
```

### Output Control

```bash
# Quiet mode
wget -q https://example.com/file.zip
wget --quiet https://example.com/file.zip

# No output except errors
wget -nv https://example.com/file.zip
wget --no-verbose https://example.com/file.zip

# Show progress bar
wget --show-progress -q https://example.com/file.zip

# Log to file
wget -o download.log https://example.com/file.zip
wget --output-file=download.log https://example.com/file.zip

# Append to log
wget -a download.log https://example.com/file.zip
wget --append-output=download.log https://example.com/file.zip

# Background download
wget -b https://example.com/largefile.zip
wget --background https://example.com/largefile.zip
# Output goes to wget-log by default
```

### Retry and Error Handling

```bash
# Retry on failure
wget --tries=5 https://example.com/file.zip

# Infinite retries
wget --tries=0 https://example.com/file.zip

# Wait between retries
wget --waitretry=10 https://example.com/file.zip

# Ignore specific HTTP errors
wget --reject-http-errors=404,403 https://example.com

# Continue on error
wget -i urls.txt --continue
```

### FTP Operations

```bash
# Download from FTP
wget ftp://ftp.example.com/file.zip

# FTP with authentication
wget ftp://username:password@ftp.example.com/file.zip

# Passive FTP
wget --passive-ftp ftp://ftp.example.com/file.zip

# Download FTP directory
wget -r ftp://ftp.example.com/pub/

# FTP with .netrc
wget ftp://ftp.example.com/file.zip
```

### Advanced Options

```bash
# Spider mode (check if files exist without downloading)
wget --spider https://example.com/file.zip

# Check HTTP status
wget --spider -S https://example.com/file.zip 2>&1 | grep "HTTP/"

# Timestamp check (download only if newer)
wget -N https://example.com/file.zip
wget --timestamping https://example.com/file.zip

# Follow redirect
wget --max-redirect=5 https://example.com

# Adjust timestamp of local file
wget --adjust-extension https://example.com/file

# Use proxy
wget -e use_proxy=yes -e http_proxy=proxy.example.com:8080 \
  https://example.com

# Robots.txt handling
wget --execute robots=off https://example.com  # Ignore robots.txt
```

### Practical Examples

```bash
# Download complete website for offline viewing
wget --mirror \
  --convert-links \
  --adjust-extension \
  --page-requisites \
  --no-parent \
  https://example.com

# Download all PDFs from website
wget -r -l1 -A.pdf https://example.com/documents/

# Download with rate limiting (for large files)
wget --limit-rate=500k -c https://example.com/large.iso

# Batch download from list with retry
wget -i urls.txt --tries=3 --waitretry=5

# Download in background and log
wget -b -o wget.log https://example.com/huge-file.zip

# Download only if newer than local file
wget -N https://example.com/updates/latest.zip

# Download and execute script
wget -O - https://example.com/install.sh | bash

# Download to stdout
wget -qO- https://example.com/api/data | jq '.'
```

---

## curl vs wget Comparison

| Feature | curl | wget |
|---------|------|------|
| Recursive download | ❌ | ✅ |
| Multiple protocols | ✅ (20+) | ✅ (HTTP/HTTPS/FTP) |
| Resume download | ✅ | ✅ |
| API testing | ✅ (Better) | ❌ |
| Upload files | ✅ | ❌ |
| HTTP methods | ✅ (All) | ✅ (Limited) |
| Output to stdout | ✅ (Default) | ❌ (By default) |
| Mirroring websites | ❌ | ✅ |
| Scripting-friendly | ✅ | ✅ |
| Link conversion | ❌ | ✅ |

### When to Use curl

- API testing and development
- Single file downloads
- Upload operations
- Complex HTTP operations
- Scripting and automation
- Supporting many protocols

### When to Use wget

- Recursive downloads
- Mirroring websites
- Batch downloads from lists
- Background downloads
- Automatic retry on failure
- When you need link conversion

---

## Practical Automation Scripts

### curl Script - API Health Check

```bash
#!/bin/bash
# api-health-check.sh

API_URL="https://api.example.com/health"
EXPECTED_STATUS=200

response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL")

if [ "$response" -eq "$EXPECTED_STATUS" ]; then
    echo "✓ API is healthy (Status: $response)"
    exit 0
else
    echo "✗ API is down (Status: $response)"
    exit 1
fi
```

### wget Script - Mirror Website

```bash
#!/bin/bash
# mirror-website.sh

SITE="$1"
OUTPUT_DIR="./mirror/$(date +%Y%m%d)"

if [ -z "$SITE" ]; then
    echo "Usage: $0 <website-url>"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

wget --mirror \
     --convert-links \
     --adjust-extension \
     --page-requisites \
     --no-parent \
     --directory-prefix="$OUTPUT_DIR" \
     --execute robots=off \
     --wait=1 \
     --random-wait \
     "$SITE"

echo "Mirror complete: $OUTPUT_DIR"
```

### curl Script - File Upload with Progress

```bash
#!/bin/bash
# upload-file.sh

FILE="$1"
UPLOAD_URL="https://example.com/upload"
API_KEY="your-api-key"

if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

curl -# -X POST "$UPLOAD_URL" \
  -H "X-API-Key: $API_KEY" \
  -F "file=@$FILE" \
  -o response.json

if [ $? -eq 0 ]; then
    echo "Upload successful"
    cat response.json | jq '.'
else
    echo "Upload failed"
    exit 1
fi
```

---

## Troubleshooting

### curl Issues

```bash
# Certificate issues
curl -k https://example.com  # Bypass (insecure)
curl --cacert /path/to/cert.pem https://example.com  # Use CA cert

# Connection timeout
curl --connect-timeout 30 https://slow-server.com

# Verbose debugging
curl -v https://example.com 2>&1 | less

# DNS issues
curl --resolve example.com:443:93.184.216.34 https://example.com

# Proxy issues
curl -x "" https://example.com  # Bypass proxy
```

### wget Issues

```bash
# Certificate issues
wget --no-check-certificate https://example.com

# Verify what wget will do (spider mode)
wget --spider -r -l 1 https://example.com

# Debug output
wget -d https://example.com

# DNS issues
echo "93.184.216.34 example.com" | sudo tee -a /etc/hosts

# Check for robots.txt blocking
wget --execute robots=off https://example.com
```

---

## Quick Reference

### curl Quick Commands

```bash
curl URL                           # GET request
curl -X POST -d "data" URL         # POST with data
curl -H "Header: value" URL        # Custom header
curl -u user:pass URL              # Basic auth
curl -O URL                        # Save with remote name
curl -o file URL                   # Save with custom name
curl -L URL                        # Follow redirects
curl -v URL                        # Verbose output
curl -s URL                        # Silent mode
curl -I URL                        # Headers only
```

### wget Quick Commands

```bash
wget URL                           # Download file
wget -O file URL                   # Custom filename
wget -c URL                        # Continue download
wget -r URL                        # Recursive download
wget -m URL                        # Mirror site
wget -i urls.txt                   # Batch download
wget -b URL                        # Background download
wget --limit-rate=200k URL         # Limit speed
wget -q URL                        # Quiet mode
wget --spider URL                  # Check without downloading
```

---

## Related Tools

- `httpie`: Modern, user-friendly HTTP client
- `aria2`: Advanced download utility with multi-threading
- `axel`: Lightweight download accelerator
- `lynx` / `links`: Text-based web browsers
- `fetch` (FreeBSD): Built-in download tool


# SSH Basics - Complete Guide

## Overview
SSH (Secure Shell) is a cryptographic network protocol for secure communication over unsecured networks. It provides encrypted remote login, command execution, file transfer, and network tunneling.

## Basic Connection Syntax

```bash
# Basic connection
ssh username@hostname
ssh username@192.168.1.100

# Specify port
ssh -p 2222 username@hostname
ssh username@hostname -p 2222

# Verbose output for debugging
ssh -v username@hostname     # Single verbose
ssh -vv username@hostname    # More verbose
ssh -vvv username@hostname   # Maximum verbosity
```

## Connection Options

### Common Flags

```bash
# Specify identity file (private key)
ssh -i ~/.ssh/id_rsa_custom username@hostname
ssh -i /path/to/private_key username@hostname

# Force TTY allocation (useful for interactive commands)
ssh -t username@hostname sudo command

# Disable TTY allocation
ssh -T username@hostname

# Compression (useful over slow networks)
ssh -C username@hostname

# Forward X11 (graphical applications)
ssh -X username@hostname      # Basic X11 forwarding
ssh -Y username@hostname      # Trusted X11 forwarding

# Background SSH (with port forwarding)
ssh -f username@hostname command

# Disable pseudo-terminal allocation
ssh -N username@hostname      # No remote command
```

### Authentication Methods

```bash
# Password authentication (interactive)
ssh username@hostname
# Then enter password when prompted

# Public key authentication
ssh -i ~/.ssh/id_rsa username@hostname

# Agent forwarding (use local keys on remote)
ssh -A username@hostname

# Specify authentication method
ssh -o PreferredAuthentications=publickey username@hostname
ssh -o PreferredAuthentications=password username@hostname
```

## Remote Command Execution

### Single Commands

```bash
# Execute single command
ssh username@hostname 'ls -la'
ssh username@hostname "df -h"

# Command with sudo (requires TTY)
ssh -t username@hostname 'sudo systemctl restart nginx'

# Multiple commands
ssh username@hostname 'cd /var/log && tail -n 20 syslog'
ssh username@hostname 'command1; command2; command3'

# Pipe local output to remote command
cat local_file.txt | ssh username@hostname 'cat > remote_file.txt'

# Pipe remote output to local command
ssh username@hostname 'cat /var/log/app.log' | grep ERROR
```

### Scripts and Heredocs

```bash
# Execute local script on remote machine
ssh username@hostname 'bash -s' < local_script.sh

# Heredoc for multiple commands
ssh username@hostname << 'EOF'
cd /var/www
git pull origin main
npm install
npm run build
sudo systemctl restart app
EOF

# With variables
APP_NAME="myapp"
ssh username@hostname << EOF
echo "Deploying $APP_NAME"
sudo systemctl restart $APP_NAME
EOF
```

## Configuration Files

### SSH Client Config (~/.ssh/config)

```bash
# Basic host configuration
Host myserver
    HostName 192.168.1.100
    User admin
    Port 22
    IdentityFile ~/.ssh/id_rsa_myserver

# Wildcard patterns
Host *.example.com
    User deploy
    Port 2222
    IdentityFile ~/.ssh/id_rsa_example

# Jump host / bastion configuration
Host internal-server
    HostName 10.0.1.50
    User appuser
    ProxyJump bastion.example.com

# Multiple jump hosts
Host target
    HostName 10.0.2.100
    ProxyJump bastion1,bastion2

# Advanced options
Host production
    HostName prod.example.com
    User deploy
    Port 22
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
    Compression yes
    LogLevel INFO

# Disable strict host key checking (use carefully)
Host testlab-*
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
```

### Using Config File

```bash
# After configuration, simply use:
ssh myserver
ssh production

# Override config options
ssh -o Port=2223 myserver
ssh -o User=root production
```

## Connection Management

### Keep Alive and Timeouts

```bash
# Keep connection alive (send packets every 60 seconds)
ssh -o ServerAliveInterval=60 username@hostname

# Maximum keep alive attempts
ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=3 username@hostname

# Set connection timeout
ssh -o ConnectTimeout=10 username@hostname

# In ~/.ssh/config
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    ConnectTimeout 10
```

### Master Connections (Connection Multiplexing)

```bash
# Enable control master in config
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 10m

# Create socket directory first
mkdir -p ~/.ssh/sockets

# First connection establishes master
ssh username@hostname

# Subsequent connections reuse master (very fast)
ssh username@hostname

# Check master connection status
ssh -O check username@hostname

# Stop master connection
ssh -O stop username@hostname

# Exit master connection
ssh -O exit username@hostname
```

## Exit Sequences

```bash
# When connected to SSH session:
~.    # Terminate connection
~^Z   # Suspend connection (put in background)
~#    # List forwarded connections
~?    # Show help for escape sequences
~C    # Open command line for port forwarding

# Note: ~ must be typed at start of line
```

## Connection Troubleshooting

### Debug Connection Issues

```bash
# Verbose debugging
ssh -vvv username@hostname 2>&1 | tee ssh_debug.log

# Test specific key
ssh -vvv -i ~/.ssh/id_rsa username@hostname

# Check if port is open
telnet hostname 22
nc -zv hostname 22

# Test SSH without executing command
ssh -T username@hostname

# Ignore known_hosts
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no username@hostname
```

### Common Issues and Solutions

```bash
# Permission denied (publickey)
# Solution: Check key permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 644 ~/.ssh/authorized_keys

# Host key verification failed
# Solution: Remove old key
ssh-keygen -R hostname
ssh-keygen -R 192.168.1.100

# Connection timeout
# Solution: Check firewall and network
ping hostname
nc -zv hostname 22

# Too many authentication failures
# Solution: Specify exact key
ssh -o IdentitiesOnly=yes -i ~/.ssh/id_rsa username@hostname
```

## Practical Examples

### Quick Operations

```bash
# Check remote system info
ssh username@hostname 'uname -a'

# Check disk space
ssh username@hostname 'df -h'

# Check memory
ssh username@hostname 'free -m'

# Check running processes
ssh username@hostname 'ps aux | grep nginx'

# View real-time logs
ssh username@hostname 'tail -f /var/log/syslog'

# Quick file backup
ssh username@hostname 'tar czf - /var/www' > backup.tar.gz

# Deploy code quickly
tar czf - ./app | ssh username@hostname 'cd /var/www && tar xzf -'
```

### Automation Scripts

```bash
#!/bin/bash
# deploy.sh - Simple deployment script

HOST="production"
REMOTE_DIR="/var/www/app"

echo "Deploying to $HOST..."

ssh $HOST << 'ENDSSH'
cd /var/www/app
git fetch origin
git reset --hard origin/main
npm install --production
npm run build
sudo systemctl restart app
echo "Deployment complete"
ENDSSH

if [ $? -eq 0 ]; then
    echo "Success!"
else
    echo "Deployment failed!"
    exit 1
fi
```

### Multi-Host Operations

```bash
#!/bin/bash
# Run command on multiple hosts

HOSTS=("server1" "server2" "server3")
COMMAND="df -h"

for host in "${HOSTS[@]}"; do
    echo "=== $host ==="
    ssh "$host" "$COMMAND"
    echo
done

# Parallel execution
for host in "${HOSTS[@]}"; do
    ssh "$host" "$COMMAND" &
done
wait
```

## Best Practices

### Security

```bash
# Always use key-based authentication
# Disable password authentication on server

# Use strong keys
ssh-keygen -t ed25519 -a 100
ssh-keygen -t rsa -b 4096

# Protect private keys
chmod 600 ~/.ssh/id_*

# Use different keys for different purposes
~/.ssh/id_ed25519_github
~/.ssh/id_ed25519_servers
~/.ssh/id_ed25519_work

# Enable agent forwarding only when needed
# Be cautious with ProxyJump and ForwardAgent

# Regular key rotation
# Audit authorized_keys regularly
```

### Performance

```bash
# Use connection multiplexing for repeated connections
# Enable compression for slow networks
# Use appropriate cipher for your needs

# Fast cipher (less secure, faster)
ssh -c aes128-gcm@openssh.com username@hostname

# Balanced cipher (default)
ssh username@hostname

# Maximum security cipher
ssh -c chacha20-poly1305@openssh.com username@hostname
```

### Maintenance

```bash
# Keep known_hosts clean
ssh-keygen -R old-hostname

# Backup SSH config and keys
cp -r ~/.ssh ~/.ssh.backup

# Document your config
# Use comments in ~/.ssh/config

# Test changes carefully
ssh -F /path/to/test/config username@hostname
```

## Quick Reference Card

```bash
# Connection
ssh user@host                          # Basic connection
ssh -p 2222 user@host                  # Custom port
ssh -i key user@host                   # Specific key

# Execution
ssh user@host command                  # Run command
ssh -t user@host sudo cmd              # Interactive command

# Debugging
ssh -v user@host                       # Verbose
ssh -vvv user@host                     # Maximum verbosity

# Options
-A          Forward authentication agent
-C          Compress data
-N          No remote command (port forwarding)
-f          Background before execution
-T          Disable TTY
-X/-Y       X11 forwarding
-o Option   Override config option
```

## Related Commands

- `ssh-keygen`: Generate and manage SSH keys
- `ssh-copy-id`: Copy public key to remote host
- `ssh-agent`: Authentication agent
- `ssh-add`: Add keys to agent
- `scp`: Secure copy files
- `sftp`: Secure file transfer
- `sshfs`: Mount remote filesystem over SSH
