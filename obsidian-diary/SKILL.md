---
name: obsidian-diary
description: 用于在 Obsidian vault 中生成每日日记条目。当用户想记录今天的工作、扫描 vault 修改文件生成日志、或自动生成每日复盘时触发。
---

# Obsidian 每日日记生成

## Vault 路径
`/Users/sto/Documents/文稿 - sto的Mac mini/Obsidian Vault`

## 执行步骤

### 1. 扫描今日修改文件
```bash
find "/Users/sto/Documents/文稿 - sto的Mac mini/Obsidian Vault" \
  -name "*.md" \
  -newer "/Users/sto/Documents/Obsidian Vault/$(date -v-1d +%Y-%m-%d).md" \
  -not -name "$(date +%Y-%m-%d).md" \
  2>/dev/null
```
如果上述命令无输出，改用按时间过滤：
```bash
find "/Users/sto/Documents/Obsidian Vault" -name "*.md" -mtime -1 \
  -not -name "$(date +%Y-%m-%d).md"
```

### 2. 读取每个修改的文件
逐一读取内容，提取关键信息。跳过图片和二进制文件。

### 3. 生成日记条目
输出路径：`/Users/sto/Documents/Obsidian Vault/YYYY-MM-DD.md`（今日日期）

**固定格式：**
```markdown
---
date: YYYY-MM-DD
tags: [diary]
---

# YYYY-MM-DD 工作日记

## 今日工作
- [[文件名]] - 一句话描述做了什么

## 关键决策
- （如有重要判断或选择，记录在此）

## 待办 / 未完成
- （记录明显未完成的事项）
```

### 4. 写入前确认
写入前先输出预览内容，询问用户是否确认写入，不要自动写入。

## 规则
- 使用 `[[文件名]]` wikilinks 引用 vault 内文件（不含扩展名）
- 如当日日记已存在，追加到文件末尾，不覆盖
- 日记文件名格式严格为 `YYYY-MM-DD.md`，放在 vault 根目录
- 摘要简洁，每条不超过一行
