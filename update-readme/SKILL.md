---
name: update-readme
description: 更新或生成 GitHub 项目的 README.md 文件，然后自动 commit 并 push 到远程仓库。当用户说"更新 README"、"帮我写 README"、"完善 README"、"update README"、"README 加上 XXX"、"README 太简陋了"、"给项目加个说明文档"、"帮我把项目文档补全"时触发。即使用户只是说"README 更新一下"或"把项目介绍写一下"也应触发此 skill。
---

# 更新 README 工作流

## 目标

理解当前项目，结合用户的具体要求，更新或生成一份清晰、实用的 README.md，然后提交并推送到远程。

## 执行步骤

### 1. 理解项目

在动笔之前，先了解这个项目是什么：

```bash
# 查看项目结构（不用太深，2层够了）
ls -la
find . -maxdepth 2 -not -path './.git/*' -not -path './node_modules/*' -not -path './__pycache__/*'

# 读取现有 README（如果有）
cat README.md 2>/dev/null || echo "(无 README)"

# 了解主要技术栈
cat package.json 2>/dev/null || cat pom.xml 2>/dev/null || cat requirements.txt 2>/dev/null || cat pyproject.toml 2>/dev/null || true
```

如果用户提了具体要改什么（比如"加上安装说明"、"把功能列表更新一下"），优先按用户要求来，不要全部重写。

### 2. 确定更新范围

区分两种情况：

**全新 README（没有或极简）**：按标准结构从头生成。

**已有 README**：只修改用户提到的部分，保留其他内容不动。不要"顺手"重构用户没让改的段落——这会让用户觉得丢失了已有的措辞和风格。

### 3. 写 README

根据项目实际情况选择合适的章节，不必每个都有。常见结构：

```markdown
# 项目名称

一句话描述这个项目是什么、解决什么问题。

## 功能特性

- 特性 1
- 特性 2

## 快速开始

### 安装

\`\`\`bash
# 安装命令
\`\`\`

### 使用

\`\`\`bash
# 使用示例
\`\`\`

## 项目结构（可选，适合较复杂项目）

## 配置（可选）

## 贡献指南（可选）

## License（可选）
```

**写作原则：**
- 用真实的命令和路径，不要写占位符（如 `your-project`）
- 技术术语保持英文（README、Git、API 等），说明文字用中文还是英文跟随项目本身风格
- 简洁为主，有用比好看重要
- badge 和图片非必须，用户没要求就不加

### 4. 写入文件

直接覆盖写入 `README.md`。如果只是局部更新，用精确的字符串替换，不要整文件重写。

### 5. Commit 并 Push

```bash
git add README.md
git commit -m "docs: update README.md"
git push
```

commit message 简洁即可。如果用户提了具体改了什么，可以稍微具体一点：
- `docs: add installation guide to README`
- `docs: update README with project structure`

## 注意事项

- 如果项目没有初始化 git 仓库，告知用户，不要强行 push
- 如果 push 被拒绝（远程有新内容），先 `git pull --rebase` 再 push
- 不要在 README 里泄露 API key、密码等敏感信息（即使源码里有）
