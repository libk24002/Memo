# CI/CD 培训分享文档 — 基于 Argo 实现

## 一、培训目标

本次培训旨在帮助学员掌握持续集成（CI）与持续交付（CD）的核心理念，理解 GitOps 模式在现代软件交付体系中的作用，并通过 Argo 系列组件（Argo CD 与 Argo Workflow）实践在 Kubernetes 环境中的 CI/CD 自动化流程。

培训目标包括：
- 理解 CI/CD 与 GitOps 的基本概念与工作机制；
- 掌握 Argo CD 的架构、部署与应用同步机制；
- 了解 Argo Workflow 的任务编排与流水线实现方式；
- 能够构建基于 Argo 的自动化交付体系；
- 掌握蓝绿部署、滚动升级、自动回滚等高级策略。

---

## 二、CI/CD 与 GitOps 基础

### 1. CI（持续集成）

持续集成（Continuous Integration）是一种软件开发实践，开发者频繁地将代码提交至主干分支，并由自动化系统执行构建、单元测试、静态检查等操作。  
目标：尽早发现集成问题，确保代码稳定性。

### 2. CD（持续交付 / 持续部署）

- **持续交付（Continuous Delivery）**：代码在通过 CI 流程后，自动部署至测试或预发布环境。
- **持续部署（Continuous Deployment）**：自动将通过测试的代码部署到生产环境。

### 3. GitOps 模式

GitOps 是一种基于 Git 的声明式运维模型：
- Git 仓库保存系统的“理想状态”（desired state）；
- 运维工具（如 Argo CD）持续监控仓库变化；
- 检测到变更后自动将其同步到 Kubernetes 集群；
- 集群状态偏离时可自动回滚或自愈。

GitOps 的核心优势：**可审计、自动化、声明式、一致性高。**

---

## 三、Argo 系列组件概述

Argo 是一组 Kubernetes 原生的开源工具，用于实现 DevOps 和 GitOps 流程。主要组件包括：

| 组件 | 功能 | 应用场景 |
|------|------|-----------|
| **Argo CD** | 持续交付与 GitOps 实现 | 监控 Git 仓库并自动同步 Kubernetes 应用 |
| **Argo Workflow** | 工作流与任务编排 | 构建 CI 流水线、测试流程、数据处理任务 |
| **Argo Events** | 事件驱动机制 | 触发 Workflow 或 CD 同步动作 |
| **Argo Rollouts** | 灰度发布、蓝绿部署 | 实现高级发布策略 |

---

## 四、Argo CD 实践

### 1. 安装 Argo CD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

验证服务状态：

```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
```

访问 UI：
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 2. Application 配置

Argo CD 使用 `Application` CRD 管理部署对象。

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: web-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/web-app.git
    targetRevision: main
    path: manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: web
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### 3. 同步与回滚

```bash
argocd app sync web-app
argocd app rollback web-app --to-revision <commit-id>
```

### 4. 自动化同步策略

Argo CD 可根据 Git 仓库自动执行同步（`auto-sync`）和资源清理（`prune`），保证集群与 Git 仓库一致。

---

## 五、Argo Workflow 实践

Argo Workflow 是 Kubernetes 上的工作流引擎，用于构建可视化的 CI 任务流。

### 1. 安装

```bash
kubectl create namespace argo
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-workflows/stable/manifests/install.yaml
```

### 2. 简单 Workflow 示例

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hello-world-
spec:
  entrypoint: hello
  templates:
  - name: hello
    container:
      image: alpine:latest
      command: ["echo"]
      args: ["Hello Argo Workflow!"]
```

运行：
```bash
kubectl create -f hello-world.yaml -n argo
```

### 3. DAG 模式

Argo 支持 DAG（有向无环图）模式，可定义依赖任务：

```yaml
spec:
  entrypoint: dag-example
  templates:
  - name: dag-example
    dag:
      tasks:
      - name: build
        template: build
      - name: test
        dependencies: [build]
        template: test
      - name: deploy
        dependencies: [test]
        template: deploy
```

---

## 六、CI/CD 集成示例

### 1. 典型流程

1. 代码提交到 Git 仓库（GitHub/GitLab）；  
2. Argo Workflow 监听代码变更并启动流水线：  
   - 构建镜像  
   - 运行单元测试  
   - 推送镜像至 Registry  
3. Argo CD 监控 GitOps 仓库并自动部署更新版本；  
4. 系统验证部署状态、回滚异常版本。

### 2. 优化策略

- **多环境管理**：dev / staging / prod 通过多分支或多目录区分  
- **蓝绿发布与 Canary 发布**：结合 Argo Rollouts 实现  
- **自动回滚**：在同步失败或探针检测异常时触发  
- **集成监控**：结合 Prometheus / Grafana / Loki 实现闭环监控  

---

## 七、总结

Argo 作为 Kubernetes 原生的 CI/CD 方案，具备以下优势：

- 完全声明式、GitOps 驱动；
- 无缝集成 Helm、Kustomize 等模板引擎；
- 工作流灵活、可视化程度高；
- 支持多团队、多环境的持续交付体系；
- 结合 Argo Events 实现端到端自动化。

通过本次培训，学员将掌握从源代码提交到集群自动化部署的完整链路，并能在企业级环境中设计和维护基于 Argo 的 DevOps 平台。
