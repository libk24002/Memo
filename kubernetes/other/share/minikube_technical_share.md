# Minikube 技术分享文档

## 一、什么是 Minikube

Minikube 是一个轻量级的工具，可在本地机器上运行 Kubernetes 集群（通常为单节点）。适用于开发、测试、学习和演示环境，但不推荐用于生产用途。

**用途与定位：**
- 本地 Kubernetes 快速演练环境
- 测试 Kubernetes 资源（Deployment、Service、Ingress、PVC 等）
- 开发阶段验证容器交互、配置、调试
- 学习 Kubernetes API、命令行操作流程

---

## 二、安装前准备

在正式启动 Minikube 之前，有一些环境准备和依赖需要确认。

### 1. 系统账户与权限
- 使用非 root 用户执行操作，如 `ben.wangz`。
- 为该用户授予 sudo 权限，便于后续执行系统级命令（安装驱动、修改网络、配置虚拟化等）：
```bash
echo 'ben.wangz ALL=(ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers
```

### 2. 安装依赖工具 / 驱动支持
根据你选用的驱动和运行时，可能需要安装以下组件：

- **Podman / Docker**：作为容器运行时
```bash
# Fedora / RHEL 示例：安装 Podman
sudo dnf install -y podman

# Ubuntu 示例：安装 Docker（简略）
sudo apt update
sudo apt install -y docker.io
```

- **虚拟化驱动**（如果使用虚拟机驱动，如 VirtualBox、KVM）：安装对应虚拟化软件与内核支持模块。
- **网络配置或安全服务处理**：某些云环境（如阿里云）可能有安全代理或防护服务（如 Aegis）会干扰，可能需要关闭相关服务：
```bash
sudo systemctl disable aegis
sudo reboot
```

### 3. 下载 Minikube 可执行文件
从官方或镜像下载 minikube 二进制文件，放置到用户路径下（如 `~/bin`），并授予可执行权限：
```bash
MIRROR="files.m.daocloud.io"
curl -LO "https://${MIRROR}/storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
mv minikube-linux-amd64 minikube
chmod +x minikube
mkdir -p ${HOME}/bin
mv minikube ${HOME}/bin
```
确认你的 `~/bin` 已在用户 `PATH` 中，或者添加：
```bash
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### 4. 安装 kubectl（可选但强烈推荐）
虽然 Minikube 自带 `minikube kubectl --` 调用方式，但建议你也单独下载 `kubectl`，便于在其他 Kubernetes 环境中复用。
```bash
MIRROR="files.m.daocloud.io"
VERSION=$(curl -sL "https://${MIRROR}/dl.k8s.io/release/stable.txt")
curl -LO "https://${MIRROR}/dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
mkdir -p ${HOME}/bin
mv kubectl ${HOME}/bin
```

---

## 三、启动 Minikube：创建本地 Kubernetes 集群

下面是一个典型的启动命令示例，以及各参数的详细说明和注意事项。
```bash
minikube start   --driver=podman   --container-runtime=cri-o   --kubernetes-version=v1.27.10   --image-mirror-country=cn   --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers   --cpus 3   --memory 12G
```

### 参数详解
| 参数 | 说明 | 备注 / 建议 |
|------|------|-------------|
| `--driver=podman` | 使用 Podman 驱动 | 如果未安装或不合适，可用 `docker`、`virtualbox`、`none` 等 |
| `--container-runtime=cri-o` | 指定容器运行时为 cri-o | 也可选 `docker`、`containerd`，需驱动兼容 |
| `--kubernetes-version=v1.27.10` | 指定 Kubernetes 版本 | 保持与生产环境或测试环境一致性 |
| `--image-mirror-country=cn` | 镜像拉取加速选项 | 在国内环境很有用 |
| `--image-repository=…` | 自定义镜像仓库地址 | 用于拉取系统组件镜像替代默认远程库 |
| `--cpus 3` | 分配给 Minikube 的 CPU 数量 | 根据宿主机能力合理设定 |
| `--memory 12G` | 分配给 Minikube 的内存 | 注意不要超过宿主机可用资源 |

### 启动后校验
- 查看节点状态：
```bash
kubectl get nodes
kubectl cluster-info
```
- 查看 Pod 状态：
```bash
kubectl get pods -A
```

### 别名与使用方便性
你可以创建一个 alias 方便调用 `kubectl`：
```bash
alias kubectl="minikube kubectl --"
```
或者直接安装 kubectl 二进制并将其放入 PATH，这样可以在多种 Kubernetes 环境中通用。

### 更改资源配置与重启集群
如果之后你希望为 Minikube 调整资源配置：
```bash
minikube config set cpus 6
minikube config set memory 16384

minikube stop
minikube start
```
这样会让 Minikube 在重新启动时应用新的资源配额。

---

## 四、服务访问方式

由于 Minikube 本地 Kubernetes 环境通常运行在 VM 或容器中，外部直接访问集群内服务稍有不同。以下是几种常见访问方法。

### 1. SSH 隧道模式
通过 SSH 隧道将宿主机端口映射到集群内部服务端口。
```bash
ssh -i ~/.minikube/machines/minikube/id_rsa docker@$(minikube ip)   -L '*:30443:0.0.0.0:30443' -N -f
```
该方法适用于需要将多个端口暴露至宿主机或局域网的场景。

### 2. kubectl port-forward
使用 Kubernetes 自带的端口转发功能，将本地端口映射到 Pod 或 Service：
```bash
kubectl port-forward -n argocd --address 0.0.0.0 service/argocd-server-external 443:30443
kubectl port-forward -n basic-components --address 0.0.0.0 service/ingress-nginx-controller 80:32080
```
优点是灵活、便捷，无需额外 SSH 隧道。

### 3. 启用 Ingress 或 LoadBalancer 插件
Minikube 支持开启一些附加组件（addons），如 Ingress、metrics-server 等：
```bash
minikube addons enable ingress
minikube addons enable metrics-server
```
开启 Ingress 后，可以在本地通过 Ingress 规则访问内部服务，模拟真实负载路径。

### 4. Minikube service 命令
Minikube 提供 `minikube service` 命令快速打开 NodePort/LoadBalancer 类型的服务访问：
```bash
minikube service nginx-deployment --url
minikube service list
```

---

## 五、管理与操作

以下是一些常用的操作流程、命令示例与注意事项。

### 查看集群信息
```bash
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
kubectl cluster-info
```

### 部署应用示例
部署一个 Nginx 服务做测试（`nginx-deployment.yaml`）：
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```
应用和暴露服务：
```bash
kubectl apply -f nginx-deployment.yaml
kubectl expose deployment nginx-deployment --type=NodePort --port=80
kubectl get svc nginx-deployment
```

### 使用持久化存储
示例 PVC + Deployment（`demo-pvc-deployment.yaml`）：
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: demo-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
      - name: demo-container
        image: busybox
        command: ["sh", "-c", "while true; do echo hello >> /data/log.txt; sleep 5; done"]
        volumeMounts:
        - name: data
          mountPath: /data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: demo-pvc
```
这能模拟数据持久化，适用于本地开发测试。

### 查看日志 / 进入 Pod
```bash
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- /bin/sh
```

### 删除 / 资源清理
```bash
kubectl delete -f nginx-deployment.yaml
kubectl delete svc nginx-deployment
kubectl delete pvc demo-pvc
minikube addons disable ingress
```

清理整个 Minikube 环境：
```bash
minikube delete --all
```

---

## 六、注意事项与最佳实践

1. **资源不要分配过高**  
   不要把主机的大部分 CPU 和内存都给 Minikube，否则主机可能变得不稳定。

2. **镜像拉取加速**  
   在国内环境下，使用镜像加速或国内镜像源对于启动速度影响很大，建议配置 `--image-repository` 或 `--image-mirror-country=cn`。

3. **存储限制**  
   Minikube 用于模拟 PV/PVC 持久化功能是可能的，但不能替代分布式或高可用存储方案。不要依赖它做真实生产存储。

4. **组件兼容性**  
   不同驱动、运行时和 Kubernetes 版本之间可能存在兼容性问题。启动时遇到错误要先查看日志与版本是否匹配。

5. **网络与端口冲突**  
   本地端口可能与 Minikube 中服务端口冲突。启动前确认未被占用。

6. **版本升级策略**  
   升级 Kubernetes 版本时要注意兼容性。可以通过 `minikube start --kubernetes-version=<version>` 指定版本，或先删除旧集群再创建新集群以避免遗留问题。

7. **使用 Addons 支持增强功能**
    - `minikube addons enable metrics-server`：用于获取资源指标
    - `minikube addons enable ingress`：支持 Ingress 路由
    - `minikube addons enable dashboard`：Kubernetes 仪表盘

8. **模拟多节点（仅用于测试）**  
   虽然 Minikube 主要设计为单节点，但可以通过多实例或使用其他工具（Kind、K3s）来做多节点测试。

---

## 七、实战演练建议

你可以结合以下练习来巩固学习效果：

1. 使用 Minikube 部署一个简单的 Web 服务 + 数据库（如 Nginx + MariaDB），设置 Service 与 Ingress，使外部可访问。
2. 使用 PVC 将数据库数据持久化，即使 Pod 重启数据不丢失。
3. 演示滚动更新：将 Web 服务升级为新版本，观察 Pod 的滚动更新和无缝切换。
4. 配置 Horizontal Pod Autoscaler，模拟负载压力，看自动扩缩容效果。
5. 启用 metrics-server、Prometheus + Grafana，展示资源监控与指标采集。
6. 模拟故障场景（如删除某个 Pod、使容器崩溃），观察 Kubernetes 的自我修复能力。
7. 结合本地代码热更新，通过 Volume 挂载实现开发时代码快速迭代。

---

## 八、附加高级主题（可选拓展）

1. **Multi-node 模拟**
    - 使用 `minikube node add`（如可用）或使用 Kind/K3s 模拟多节点集群，以测试调度、亲和性、反亲和性等特性。

2. **使用 Minikube 的 Docker 环境构建镜像**
    - 通过 `eval $(minikube -p minikube docker-env)` 切换到 Minikube 的 Docker 环境，直接在本地构建镜像并部署到集群而无需推送到远程仓库。

3. **结合 CI/CD**
    - 将 Minikube 用作 CI 管道中的测试环境（注意资源和并发限制），在 CI 步骤中启动 Minikube、运行测试、销毁集群。

4. **自定义 CNI/Network Plugin**
    - 在 Minikube 中尝试安装不同的 CNI 插件（如 Calico、Cilium）以测试网络策略和网络性能。

5. **Operator 与 CRD 开发**
    - 在本地 Minikube 上测试自定义资源定义（CRD）和 Operator 的开发与调试流程。

---

## 九、总结

Minikube 是进入 Kubernetes 世界的理想工具：安装便捷、资源轻量、功能完备，适合学习与验证各类 Kubernetes 特性。  
通过本文档的安装配置与实战练习，用户可以快速搭建本地测试环境、验证部署流程、调试应用以及熟悉 Kubernetes 的运维操作。

下一步建议：
- 在培训中结合实操演示：从安装、创建集群、部署应用、暴露服务、持久化存储、到监控告警，完整演示一遍；
- 将实操题目打包成练习册，供学员课后复习；
- 引导学员将本地经验迁移到测试/预发布环境（Kind、K3s、云上集群）。

---

## 十、参考资料
- Minikube 官方文档：https://minikube.sigs.k8s.io/docs/
- Kubernetes 官方文档：https://kubernetes.io/docs/home/
