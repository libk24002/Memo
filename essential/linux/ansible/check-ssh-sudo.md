# 检查 SSH 与 Sudo 权限

## 概述

在使用 Ansible 进行自动化部署和配置管理时，确保目标主机具有正确的 SSH 连接和 Sudo 权限是非常重要的前提条件。本文档详细介绍如何使用 Ansible 检查目标主机的 SSH 连接和 Sudo 权限状态。

## 任务描述

以下 Ansible 任务用于检查目标主机的 SSH 连接和 Sudo 权限：

```yaml
- name: 🧱 1. 检查 SSH 与 Sudo
  ansible.builtin.command: whoami
  become: yes
```

### 参数说明

- **ansible.builtin.command**: 使用 Ansible 内置的 command 模块执行命令
- **whoami**: 执行的命令，用于显示当前用户名
- **become: yes**: 启用权限提升，相当于使用 sudo 执行命令

## 工作原理

1. **SSH 连接检查**：
   - Ansible 尝试通过 SSH 连接到目标主机
   - 如果连接成功，表示 SSH 配置正确
   - 如果连接失败，Ansible 将报告错误

2. **Sudo 权限检查**：
   - `become: yes` 指示 Ansible 使用 sudo 执行 `whoami` 命令
   - 如果目标主机上的用户具有 sudo 权限，命令将成功执行并返回 `root`
   - 如果用户没有 sudo 权限，任务将失败并显示权限错误

## 预期输出

成功执行后，该任务的输出应该类似于：

```
TASK [🧱 1. 检查 SSH 与 Sudo] *************************************************
changed: [host1] => {"changed": true, "cmd": ["whoami"], "delta": "0:00:00.003644", "end": "2023-06-15 10:15:23.456789", "rc": 0, "start": "2023-06-15 10:15:23.453145", "stderr": "", "stderr_lines": [], "stdout": "root", "stdout_lines": ["root"]}
```

## 前提条件

1. **SSH 配置**：
   - 控制节点必须能够通过 SSH 密钥认证连接到目标主机
   - 目标主机上的用户必须在 `authorized_keys` 文件中包含控制节点的公钥

2. **Sudo 配置**：
   - 目标主机上的用户必须具有 sudo 权限
   - 理想情况下，sudo 应配置为无密码执行（NOPASSWD）

## 配置示例

### SSH 密钥配置

在控制节点上：

```bash
# 生成 SSH 密钥对（如果尚未生成）
ssh-keygen -t rsa -b 4096

# 将公钥复制到目标主机
ssh-copy-id username@target_host
```

### Sudo 配置

在目标主机上编辑 sudoers 文件：

```bash
# 使用 visudo 编辑 sudoers 文件
sudo visudo

# 添加以下行以允许用户无密码执行 sudo 命令
username ALL=(ALL) NOPASSWD: ALL
```

## 常见问题与故障排除

### SSH 连接问题

1. **连接被拒绝**：
   - 检查目标主机的 SSH 服务是否运行
   - 确认 SSH 端口（默认 22）是否开放
   - 验证用户名是否正确

2. **认证失败**：
   - 确认公钥已正确添加到目标主机的 `~/.ssh/authorized_keys` 文件中
   - 检查 `~/.ssh/authorized_keys` 文件的权限（应为 600）
   - 检查 `~/.ssh` 目录的权限（应为 700）

### Sudo 权限问题

1. **Sudo 密码提示**：
   - 如果执行时出现密码提示，表示用户的 sudo 配置未设置 NOPASSWD
   - 修改 sudoers 文件，添加 NOPASSWD 选项

2. **Sudo 权限不足**：
   - 确认用户已添加到 sudoers 文件或 sudo 组
   - 检查 sudoers 文件中的配置是否正确

## 最佳实践

1. **使用专用的 Ansible 用户**：
   - 创建专用于 Ansible 自动化的用户账户
   - 仅授予该用户所需的最小权限

2. **限制 Sudo 权限范围**：
   - 避免使用 `ALL=(ALL) NOPASSWD: ALL`，这过于宽松
   - 仅允许执行特定命令，例如：`username ALL=(ALL) NOPASSWD: /bin/systemctl, /usr/bin/apt`

3. **定期轮换 SSH 密钥**：
   - 定期更新 SSH 密钥以提高安全性
   - 使用密钥管理系统管理多个目标主机的密钥

4. **使用 Ansible Vault 保护敏感信息**：
   - 对包含密码或敏感信息的变量使用 Ansible Vault 加密

## 相关资源

- [Ansible 官方文档 - 权限提升](https://docs.ansible.com/ansible/latest/user_guide/become.html)
- [Ansible 官方文档 - SSH 连接](https://docs.ansible.com/ansible/latest/user_guide/connection_details.html)
- [Linux sudo 命令详解](https://man7.org/linux/man-pages/man8/sudo.8.html)