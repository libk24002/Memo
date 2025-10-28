# Conti Memo

[![部署状态](https://img.shields.io/badge/部署-在线-success)](https://memo.cnconti.tech)
[![MkDocs](https://img.shields.io/badge/MkDocs-Material-blue)](https://squidfunk.github.io/mkdocs-material/)
[![许可证](https://img.shields.io/badge/license-MIT-green)](LICENSE)

> 个人技术文档和学习笔记集合

## 📖 项目简介

这是一个使用 MkDocs Material 主题构建的技术文档站点，主要收录了我在学习和工作中积累的各类技术笔记和经验总结。

🔗 **在线访问**: [memo.cnconti.tech](https://memo.cnconti.tech)

## 📚 内容目录

### 基础工具 (Essential)
- **Linux** - Linux 系统相关知识
  - 网络基础与协议
  - 存储管理（LVM）
  - 虚拟化技术（QEMU）
- **Git** - Git 版本控制
- **Docker** - Docker 容器技术
- **Commands** - 常用命令集合

### 理论知识 (Theories)
- **Computer** - 计算机基础理论
- **Mathematical** - 数学理论
- **Algorithm** - 算法与数据结构
- **Architecture** - 架构设计
- **Storage** - 存储技术

## 🚀 快速开始

### 环境要求

- Python 3.8+
- pip

### 本地运行

1. 克隆仓库
```bash
git clone https://github.com/libk24002/Memo.git
cd Memo
```

2. 安装依赖
```bash
pip install -r requirements.txt
```

3. 启动开发服务器
```bash
mkdocs serve
```

4. 浏览器访问 `http://localhost:8000`

### 构建静态网站

```bash
mkdocs build
```

生成的静态文件将保存在 `site/` 目录下。

## 📝 文档编写

文档使用 Markdown 格式编写，存放在 `docs/` 目录下。

- 所有文档文件使用 `.md` 扩展名
- 图片资源存放在对应章节的 `resources/` 或 `resorces/` 目录下
- 遵循 [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) 的语法规范

## 🛠️ 技术栈

- [MkDocs](https://www.mkdocs.org/) - 文档生成器
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) - Material Design 主题
- [GitHub Pages](https://pages.github.com/) - 网站托管

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 👤 作者

**Libk24002**

- GitHub: [@libk24002](https://github.com/libk24002)
- 网站: [memo.cnconti.tech](https://memo.cnconti.tech)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

⭐ 如果这个项目对你有帮助，欢迎 Star！
