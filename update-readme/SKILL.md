---
name: update-readme
description: 更新或生成 GitHub 项目的 README.md 文件，然后自动 commit 并 push 到远程仓库。当用户说"更新 README"、"帮我写 README"、"完善 README"、"update README"、"README 加上 XXX"、"README 太简陋了"、"给项目加个说明文档"、"帮我把项目文档补全"时触发。即使用户只是说"README 更新一下"或"把项目介绍写一下"也应触发此 skill。
---

# 更新 README 工作流

## 目标

理解当前项目，结合用户的具体要求，更新或生成一份清晰、实用的 README，然后提交并推送到远程。

## 执行步骤

### 1. 理解项目

在动笔之前，先了解这个项目是什么：

```bash
# 查看项目结构（不用太深，2层够了）
ls -la
find . -maxdepth 2 -not -path './.git/*' -not -path './node_modules/*' -not -path './__pycache__/*'

# 读取现有 README（如果有）
cat README.md 2>/dev/null || echo "(无 README)"
cat README_zh.md 2>/dev/null || true

# 了解主要技术栈
cat package.json 2>/dev/null || cat pom.xml 2>/dev/null || cat requirements.txt 2>/dev/null || cat pyproject.toml 2>/dev/null || true
```

如果用户提了具体要改什么（比如"加上安装说明"、"把功能列表更新一下"），优先按用户要求来，不要全部重写。

### 2. 确定更新范围

区分两种情况：

**全新 README（没有或极简）**：按标准结构从头生成，默认生成双语版本。

**已有 README**：只修改用户提到的部分，保留其他内容不动。不要"顺手"重构用户没让改的段落。

### 3. 双语结构

默认生成中英文双语 README，通过两个文件实现语言切换：

- `README.md` -- 英文版（GitHub 默认展示）
- `README_zh.md` -- 中文版

每个文件顶部添加语言切换链接：

**README.md 顶部：**
```markdown
[中文](README_zh.md) | English
```

**README_zh.md 顶部：**
```markdown
[English](README.md) | 中文
```

两个文件的章节结构保持一致，内容互为翻译。更新任何一个文件时，必须同步更新另一个文件的对应部分。

如果项目已有单语 README 且用户没有要求双语，保持现状即可。

### 4. 写 README

根据项目实际情况选择合适的章节，不必每个都有。

**英文版（README.md）常见结构：**

```markdown
[中文](README_zh.md) | English

# Project Name

One-line description of what this project does.

## Features

- Feature 1
- Feature 2

## Installation

\`\`\`bash
# install command
\`\`\`

## Usage

\`\`\`bash
# usage example
\`\`\`

## Project Structure (optional)

## Configuration (optional)

## Contributing (optional)

## License (optional)
```

**中文版（README_zh.md）常见结构：**

```markdown
[English](README.md) | 中文

# 项目名称

一句话描述这个项目是什么、解决什么问题。

## 功能特性

- 特性 1
- 特性 2

## 安装

\`\`\`bash
# 安装命令
\`\`\`

## 使用方法

\`\`\`bash
# 使用示例
\`\`\`

## 项目结构（可选）

## 配置（可选）

## 贡献指南（可选）

## License（可选）
```

**写作原则：**
- 用真实的命令和路径，不要写占位符（如 `your-project`）
- 英文版用自然的英文表达，不是逐字翻译中文；中文版同理
- 技术术语（API、Git、Shadow DOM 等）两个版本都保持英文
- 代码块、命令、文件路径两个版本保持一致，不需要翻译
- 简洁为主，有用比好看重要
- badge 和图片非必须，用户没要求就不加

### 5. 写入文件

新建时用 Write 工具创建。局部更新时用 Edit 工具做精确替换，不要整文件重写。

更新一个语言版本时，必须检查并同步另一个版本。

### 6. Commit 并 Push

```bash
git add README.md README_zh.md
git commit -m "docs: update README"
git push
```

commit message 简洁即可。如果用户提了具体改了什么，可以稍微具体一点：
- `docs: add installation guide to README`
- `docs: update README with project structure`

## 注意事项

- 如果项目没有初始化 git 仓库，告知用户，不要强行 push
- 如果 push 被拒绝（远程有新内容），先 `git pull --rebase` 再 push
- 不要在 README 里泄露 API key、密码等敏感信息（即使源码里有）
- 如果项目只有单语 README 且用户只要求更新内容（未提双语），不要自作主张添加第二语言版本
