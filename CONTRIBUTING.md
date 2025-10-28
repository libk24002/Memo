# 贡献指南

感谢你对本项目的关注！欢迎任何形式的贡献。

## 🤝 如何贡献

### 报告问题

如果你发现了文档中的错误或有改进建议：

1. 在 [Issues](https://github.com/libk24002/Memo/issues) 页面搜索是否已有类似问题
2. 如果没有，创建一个新的 Issue
3. 清晰地描述问题或建议
4. 如果可能，提供截图或相关代码

### 提交更改

1. **Fork 本仓库**

2. **克隆到本地**
   ```bash
   git clone https://github.com/your-username/Memo.git
   cd Memo
   ```

3. **创建新分支**
   ```bash
   git checkout -b feature/your-feature-name
   # 或
   git checkout -b fix/your-fix-name
   ```

4. **进行更改**
   - 遵循现有的文档风格
   - 确保 Markdown 语法正确
   - 添加必要的图片和代码示例

5. **本地测试**
   ```bash
   # 安装依赖
   pip install -r requirements.txt
   
   # 启动本地服务器
   mkdocs serve
   
   # 访问 http://localhost:8000 查看效果
   ```

6. **提交更改**
   ```bash
   git add .
   git commit -m "描述你的更改"
   git push origin feature/your-feature-name
   ```

7. **创建 Pull Request**
   - 在 GitHub 上创建 Pull Request
   - 清晰地描述你的更改
   - 等待审核

## 📝 文档规范

### Markdown 格式

- 使用中文标点符号
- 代码块指定语言类型
- 合理使用标题层级（不要跳级）
- 添加必要的说明和注释

### 文档结构

```
docs/
├── index.md           # 首页
├── linux/             # Linux 相关
│   ├── README.md      # 分类首页
│   ├── network/       # 网络
│   ├── storage/       # 存储
│   └── ...
├── git/               # Git 相关
└── ...
```

### 图片资源

- 图片放在文档同级的 `resources/` 或 `resorces/` 目录
- 使用有意义的文件名
- 优先使用 PNG 或 SVG 格式
- 图片大小控制在 500KB 以内

### 代码示例

- 提供完整的可运行示例
- 添加必要的注释
- 说明运行环境和依赖

示例：

````markdown
```bash
# 更新系统
sudo apt update
sudo apt upgrade -y

# 安装软件
sudo apt install vim
```
````

### 使用 Admonition

适当使用提示框：

````markdown
!!! note "提示"
    这是一个提示信息

!!! warning "警告"
    这是一个警告信息

!!! danger "危险"
    这是一个危险操作提示

!!! tip "技巧"
    这是一个小技巧
````

## 🎯 贡献内容建议

欢迎贡献以下类型的内容：

- 修正错误和错别字
- 改进现有文档的可读性
- 添加新的技术文档
- 添加实用的代码示例
- 补充图片和图表
- 翻译外文资料
- 改进文档结构

## ✅ 提交前检查清单

- [ ] 文档内容准确无误
- [ ] Markdown 语法正确
- [ ] 代码示例可以正常运行
- [ ] 图片资源已添加到仓库
- [ ] 本地预览效果正常
- [ ] commit 信息清晰明确

## 📧 联系方式

如有任何问题，可以通过以下方式联系：

- 提交 Issue
- 发送邮件到项目维护者

## 📄 许可证

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE) 文件。

贡献即表示你同意你的贡献将在 MIT 许可证下发布。

---

再次感谢你的贡献！🎉

