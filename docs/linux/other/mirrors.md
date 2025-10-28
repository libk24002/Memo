# Linux 镜像源配置

!!! info "镜像源简介"
    镜像源（Mirror）是软件包仓库的镜像站点，使用国内镜像源可以大幅提升软件包的下载速度。

## 🇨🇳 常用国内镜像源

### 主流镜像站

| 镜像站 | 网址 | 特点 |
|--------|------|------|
| 清华大学 | https://mirrors.tuna.tsinghua.edu.cn/ | 速度快，稳定 |
| 中科大 | https://mirrors.ustc.edu.cn/ | 老牌镜像站 |
| 阿里云 | https://mirrors.aliyun.com/ | 商业级稳定性 |
| 华为云 | https://mirrors.huaweicloud.com/ | 企业级支持 |
| 网易 | https://mirrors.163.com/ | 速度稳定 |

## 🐧 Ubuntu/Debian 镜像源配置

### Ubuntu 22.04 LTS (Jammy)

```bash
# 备份原始源文件
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

# 编辑源文件
sudo nano /etc/apt/sources.list
```

**清华大学镜像源**:

```bash
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse

# 安全更新
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
```

**阿里云镜像源**:

```bash
deb https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
```

### Debian 12 (Bookworm)

**清华大学镜像源**:

```bash
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
```

### 更新源

```bash
# 更新软件包列表
sudo apt update

# 升级已安装的软件包
sudo apt upgrade -y
```

## 🎩 CentOS/RHEL/Rocky Linux 镜像源配置

### CentOS 7

**清华大学镜像源**:

```bash
# 备份原始源
sudo mkdir -p /etc/yum.repos.d/backup
sudo mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/

# 下载清华源配置
sudo curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.tuna.tsinghua.edu.cn/help/centos/7/CentOS-Base.repo

# 清除缓存并重建
sudo yum clean all
sudo yum makecache
```

### CentOS Stream 8/9

```bash
# Stream 8
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo

# Stream 9
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.stream.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
         -i.bak \
         /etc/yum.repos.d/*.repo

# 清除缓存
sudo dnf clean all
sudo dnf makecache
```

### Rocky Linux 9

```bash
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://dl.rockylinux.org/\$contentdir|baseurl=https://mirrors.tuna.tsinghua.edu.cn/rocky|g' \
         -i.bak \
         /etc/yum.repos.d/rocky*.repo

sudo dnf clean all
sudo dnf makecache
```

## 🎯 Fedora 镜像源配置

```bash
# 备份原始源
sudo mkdir -p /etc/yum.repos.d/backup
sudo mv /etc/yum.repos.d/fedora*.repo /etc/yum.repos.d/backup/

# 使用清华源
sudo curl -o /etc/yum.repos.d/fedora.repo https://mirrors.tuna.tsinghua.edu.cn/help/fedora/fedora.repo
sudo curl -o /etc/yum.repos.d/fedora-updates.repo https://mirrors.tuna.tsinghua.edu.cn/help/fedora/fedora-updates.repo

# 更新缓存
sudo dnf clean all
sudo dnf makecache
```

## 🐍 Python pip 镜像源配置

### 临时使用

```bash
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple package_name
```

### 永久配置

**Linux/macOS**:

```bash
# 创建配置文件
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF
```

**Windows**:

在 `%APPDATA%\pip\pip.ini` 创建文件，内容为：

```ini
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
```

### 常用 PyPI 镜像

```bash
# 清华大学
https://pypi.tuna.tsinghua.edu.cn/simple

# 阿里云
https://mirrors.aliyun.com/pypi/simple/

# 中科大
https://pypi.mirrors.ustc.edu.cn/simple/

# 华为云
https://mirrors.huaweicloud.com/repository/pypi/simple
```

## 📦 Docker 镜像源配置

### Docker Hub 镜像加速

编辑 `/etc/docker/daemon.json`:

```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.ccs.tencentyun.com"
  ]
}
```

重启 Docker:

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 🔧 Node.js npm 镜像源配置

### 临时使用

```bash
npm install --registry=https://registry.npmmirror.com package_name
```

### 永久配置

```bash
# 设置淘宝镜像
npm config set registry https://registry.npmmirror.com

# 查看当前源
npm config get registry

# 恢复官方源
npm config set registry https://registry.npmjs.org
```

### 使用 nrm 管理源

```bash
# 安装 nrm
npm install -g nrm

# 列出可用源
nrm ls

# 切换到淘宝源
nrm use taobao

# 测试速度
nrm test
```

## 🦀 Rust Cargo 镜像源配置

编辑 `~/.cargo/config.toml`:

```toml
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "https://mirrors.ustc.edu.cn/crates.io-index"

# 或使用清华源
[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
```

## 📱 Android SDK 镜像源配置

### 使用清华大学镜像

在 Android Studio 中设置 HTTP Proxy:

```
HTTP Proxy: mirrors.tuna.tsinghua.edu.cn
Port: 80
```

或编辑 `~/.gradle/gradle.properties`:

```properties
systemProp.http.proxyHost=mirrors.tuna.tsinghua.edu.cn
systemProp.http.proxyPort=80
systemProp.https.proxyHost=mirrors.tuna.tsinghua.edu.cn
systemProp.https.proxyPort=80
```

## 🔍 镜像源测速工具

### apt-fast (Debian/Ubuntu)

```bash
# 安装
sudo add-apt-repository ppa:apt-fast/stable
sudo apt update
sudo apt install apt-fast

# 使用（自动选择最快源）
sudo apt-fast install package_name
```

### netselect-apt (Debian/Ubuntu)

```bash
# 安装
sudo apt install netselect-apt

# 自动选择最快的源
sudo netselect-apt
```

## 💡 最佳实践

1. **定期更新**: 切换镜像源后记得执行更新命令
2. **备份原始配置**: 修改前务必备份原始配置文件
3. **选择就近原则**: 优先选择地理位置近的镜像站
4. **多源备份**: 可以配置多个镜像源作为备份
5. **验证有效性**: 配置后测试是否能正常下载

## 🔗 参考链接

- [清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/)
- [中科大开源软件镜像](https://mirrors.ustc.edu.cn/)
- [阿里巴巴开源镜像站](https://developer.aliyun.com/mirror/)

---

!!! tip "提示"
    如果某个镜像源访问缓慢或失败，及时切换到其他镜像源。
