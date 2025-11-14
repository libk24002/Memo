## mirror-apt

### Content
1. 启动一个镜像，用于相关镜像同步工作
    * prepare [sync-ubuntu-22.04.sh](sync-ubuntu-22.04.sh)
    * ```shell
      docker run --rm --init \
          --name mirrors-apt-ubuntu-22.04 \
          -v $PWD/sync-ubuntu-22.04.sh:/app/entrypoint.sh:ro \
          -v $PWD/mirrors:/data:rw \
          --entrypoint /app/entrypoint.sh \
          -d m.lab.zverse.space/docker.io/library/debian:bullseye
      ```

2. 使用 nginx 提供 APT 镜像服务
    * ```shell
      docker run --rm \
          --name mirrors-apt \
          -p 30000:80 \
          -v /opt/mirrors/apt/data:/usr/share/nginx/html \
          -v /opt/mirrors/apt/nginx.conf:/etc/nginx/nginx.conf:ro \
          -d docker.io/library/nginx:1.23.4-bullseye
      ```

### 同步脚本示例

```bash
#!/bin/bash

# Base directories
DIST_BASE="/app/ubuntu/dists"
POOL_BASE="/app/ubuntu/pool"

# Mirrors
MIRROR="rsync://mirrors.tuna.tsinghua.edu.cn/ubuntu"

# Sync dists
for DIST in jammy jammy-backports jammy-proposed jammy-security jammy-updates; do
    echo ">>> Syncing dists: $DIST ..."
    rsync -avz --delete ${MIRROR}/dists/${DIST} ${DIST_BASE}
done

# Sync pools
for SECTION in main restricted universe multiverse; do
    echo ">>> Syncing pool: $SECTION ..."
    rsync -avz --delete ${MIRROR}/pool/${SECTION} ${POOL_BASE}
done

echo ">>> Ubuntu 22.04 mirror sync finished!"
```
