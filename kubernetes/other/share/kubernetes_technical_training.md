# Kubernetes 技术培训分享文档

## 一、培训目标
本次培训旨在让参与者掌握 Kubernetes（简称 K8s）基础知识、核心概念、常用命令及实际操作能力，理解 Kubernetes 在容器编排、资源调度、自动化部署和服务管理中的作用，并通过实践掌握从容器部署到服务发布的完整流程。

---

## 二、Kubernetes 简介

### 1. 背景介绍
Kubernetes 是由 Google 在 2014 年发起并开源的容器集群管理系统，基于其十多年大规模容器管理系统 **Borg** 的经验开发而来。  
Kubernetes 能够实现容器化应用的自动部署、扩展、管理与维护，是当前主流的云原生基础设施核心组件。

### 2. 核心优势
- **可移植性（Portability）**  
  支持公有云、私有云、混合云、多云部署场景。
- **可扩展性（Extensibility）**  
  模块化、插件化设计，支持自定义控制器与调度器。
- **自动化（Automation）**  
  自动部署、自动修复、自动伸缩、自动回滚等。

### 3. Kubernetes 带来的变革

Kubernetes 不仅主宰了容器编排领域，更深刻改变了传统运维模式：
- **DevOps 实践深化**：开发与运维界限模糊，快速迭代部署成为常态；
- **服务定义化**：每个工程师都可通过 YAML 文件定义服务拓扑、节点数量及资源使用；
- **高效资源利用**：通过调度算法实现资源利用最大化；
- **标准化交付流程**：蓝绿部署、滚动更新、A/B 测试等成为标准手段。

---

## 三、Kubernetes 核心概念

### 1. 服务发现与负载均衡（Service Discovery & Load Balancing）

Kubernetes 使用 **Service** 对象实现服务发现与负载均衡功能。  
- 每个 Pod 都有独立的 IP；
- Service 提供统一访问入口；
- 内置 kube-proxy 支持负载均衡。

```bash
# 查看所有 Service
kubectl get svc

# 创建一个简单的 NodePort 服务
kubectl expose deployment nginx-deployment --type=NodePort --port=80
```

---

### 2. 存储编排（Storage Orchestration）

Kubernetes 支持挂载多种类型的存储，如：
- 本地存储
- NFS
- 公有云存储（AWS EBS、GCE PD、Azure Disk）
- 动态卷（PVC/PV）

**示例：PVC 定义**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

---

### 3. 自动部署与回滚（Deployment & Rollback）

使用 **Deployment** 对象描述容器的目标状态。  
Kubernetes 会自动调度容器副本，保障状态一致性，并支持版本控制与自动回滚。

```bash
# 部署应用
kubectl apply -f deployment.yaml

# 查看历史版本
kubectl rollout history deployment my-app

# 回滚至上一个版本
kubectl rollout undo deployment my-app
```

---

### 4. 自动资源调度（Resource Scheduling）

通过定义容器的资源请求与限制（requests / limits），Kubernetes 能在集群中做出智能调度。

```yaml
resources:
  requests:
    cpu: "500m"
    memory: "256Mi"
  limits:
    cpu: "1"
    memory: "512Mi"
```

---

### 5. 自我修复（Self-Healing）

Kubernetes 控制器会持续监测 Pod 的健康状态，自动重启失败的容器、替换异常节点上的 Pod，保证服务持续可用。

```bash
# 查看 Pod 状态
kubectl get pods -o wide

# 模拟删除 Pod
kubectl delete pod my-app-xxxxxx

# 控制器会自动重建
```

---

### 6. 密钥与配置管理（Secrets & ConfigMaps）

Kubernetes 提供了安全管理应用配置和敏感信息的机制。

- **ConfigMap**：存储普通配置；
- **Secret**：存储敏感数据（密码、令牌等）。

```bash
# 创建 Secret
kubectl create secret generic db-secret --from-literal=password=MyPassw0rd

# 查看 Secret
kubectl get secret db-secret -o yaml
```

---

## 四、可视分析项目中使用的 K8s 概念

| 功能模块 | 对应 K8s 概念 | 应用场景 |
|-----------|----------------|------------|
| 服务注册与访问 | Service + Deployment | 实现负载均衡和自动发现 |
| 日志持久化 | PVC + PV | 容器日志的长期保存 |
| 自动部署与回滚 | Deployment + CI/CD | DevOps 流程中快速迭代 |
| 自我修复 | ReplicaSet | 确保基础 Pod 数量稳定 |
| 密钥与配置 | Secret + ConfigMap | 管理中间件的访问凭据 |

---

## 五、后续可测试与优化方向

1. **存活检测（Liveness & Readiness Probes）**
   - 定义容器健康检测探针；
   - 自动检测失败并重启。

2. **动态扩缩容（Horizontal Pod Autoscaler）**
   - 根据 CPU/内存/自定义指标动态调整 Pod 数量；
   - 可结合 Metrics Server 实现自动伸缩。

3. **中间件优化**
   - 通过 Helm 管理中间件；
   - 自动注入配置与 Secret；
   - 优化数据库、消息队列等部署策略。

---

## 六、Kubernetes 常用命令汇总

| 操作 | 命令 |
|------|------|
| 查看节点 | `kubectl get nodes` |
| 查看 Pod | `kubectl get pods -A` |
| 查看 Service | `kubectl get svc` |
| 查看 Deployment | `kubectl get deploy` |
| 查看日志 | `kubectl logs <pod-name>` |
| 进入容器 | `kubectl exec -it <pod-name> -- /bin/bash` |
| 查看资源使用 | `kubectl top pods` |
| 删除资源 | `kubectl delete -f xxx.yaml` |

---

## 七、实操演示

### 演示一：持久化部署示例

目标：完成应用持久化存储与服务暴露。  

步骤：
1. 创建 PVC（持久化卷声明）；
2. 创建 Deployment（应用部署）；
3. 创建 Service（服务暴露 NodePort）。

验证方式：
- 使用 `kubectl get pv,pvc,svc` 查看状态；
- 访问 NodePort 地址验证访问。

---

### 演示二：Simulation 镜像部署与日志持久化

目标：部署 simulation 应用并实现日志持久化。

步骤：
1. 创建 PVC；
2. 使用 Deployment 启动 simulation 镜像；
3. 日志目录挂载至持久化卷；
4. 使用 `kubectl logs` 验证日志输出。

---

### 演示三：使用 Helm 安装 MariaDB

目标：通过 Helm 快速部署数据库组件。

```bash
# 添加 Helm 仓库
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# 安装 MariaDB
helm install my-mariadb bitnami/mariadb

# 验证数据库运行
kubectl get pods
kubectl exec -it my-mariadb-0 -- mysql -u root -p
```

---

## 八、最佳实践与运维建议

### 1. 集群资源管理
- 定期清理未使用的资源（如旧 PVC、未引用的镜像）；
- 监控节点负载，合理分配资源请求与限制；
- 使用 `kubectl top`、Prometheus + Grafana 等工具做可视化监控。

### 2. 日志与监控
- 使用 EFK（Elasticsearch + Fluentd + Kibana）或 Loki + Grafana 构建日志系统；
- 结合 metrics-server 与 Prometheus 实现性能指标采集。

### 3. 安全管理
- 合理分配 RBAC 权限，遵循最小权限原则；
- 使用 Secret 管理敏感数据；
- 定期更新镜像，修复安全漏洞。

### 4. DevOps 集成
- 结合 Jenkins/GitLab CI 实现持续交付；
- 使用 Helm 管理复杂应用；
- 通过 ArgoCD 或 Flux 实现 GitOps 流程。

---

## 九、总结与展望

Kubernetes 已成为现代云原生架构的核心。  
通过本次培训，期望参训者能够：

- 掌握 Kubernetes 基础操作与概念；
- 理解服务编排与资源调度机制；
- 能够将 simulation、数据库等服务容器化并稳定运行；
- 为后续 DevOps 流程优化与自动化扩展打下基础。

> 下一阶段，我们将结合实际业务场景，进一步探索 Kubernetes Operator、自定义控制器（CRD）及多集群管理技术。

---

**附录**  
- 官方文档：https://kubernetes.io/docs/home/  
- Helm 文档：https://helm.sh/docs/  
- kubectl 命令参考：https://kubernetes.io/docs/reference/kubectl/
