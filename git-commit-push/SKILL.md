---
name: git-commit-push
description: 完整的 Git 提交并推送工作流。当用户说"提交并推送"、"commit and push"、"push 一下"、"帮我提交"、"提交代码"、"push my changes"、"push 到 GitHub"、"上传代码"、"同步到远程"时触发。即使用户只是说"push 一下"或"提交一下"也应触发此 skill 来完成完整的 commit + push 流程。
---

# Git Commit & Push 工作流

## 目标

帮助用户完成完整的提交流程：查看变更 → 暂存文件 → 生成规范的 commit message → 创建 commit → 推送到远程。

## 执行步骤

### 1. 查看当前状态

先运行以下命令了解现状：

```bash
git status
git diff --stat
git log --oneline -5  # 参考历史 commit 风格
```

### 2. 确定要暂存的文件

- 如果用户明确指定了文件，只暂存那些文件
- 如果用户说"全部"或没有指定，暂存所有已修改/新增文件（不含明显不该提交的：`.env`、密钥文件、大型二进制文件等）
- 遇到可疑文件（如 `.env`、`credentials*`、`*.key`）要明确告知用户并跳过

```bash
git add <具体文件>   # 或 git add -A（全部时）
```

### 3. 生成 Commit Message

遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>(<scope>): <简短描述>

[可选正文]

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

**type 选择依据：**
- `feat` — 新功能
- `fix` — bug 修复
- `chore` — 构建/依赖/配置/日常维护，不影响业务逻辑
- `docs` — 文档
- `refactor` — 重构（不新增功能，不修 bug）
- `test` — 测试
- `style` — 代码格式（不影响逻辑）
- `perf` — 性能优化

**写好 commit message 的原则：**
- 标题用英文、祈使句，50 字以内
- 标题说 "what"，正文说 "why"（如果不显而易见）
- scope 可选，填改动所在模块/目录名

**示例：**
- `chore: remove unused apify skills`
- `feat(auth): add JWT token refresh logic`
- `fix(api): handle null response from payment gateway`

### 4. 创建 Commit

用 HEREDOC 传入 message，避免特殊字符转义问题：

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <描述>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

### 5. 推送到远程

```bash
git push
```

如果是新分支（没有 upstream），用：

```bash
git push -u origin <branch-name>
```

**推送前检查：**
- 确认当前分支不是 `main`/`master` 的 force push（绝不允许）
- 如果是已有 upstream 的分支，直接 `git push`

### 6. 确认结果

推送成功后告知用户：

```
已推送到 origin/<branch>，commit: <hash> — <message>
```

## 注意事项

- 涉及密钥、`.env`、`credentials` 等敏感文件，直接跳过并告知
- 遇到 pre-commit hook 失败，先修复问题再重新 commit，不要加 `--no-verify`
- 遇到推送冲突（rejected），先 `git pull --rebase` 再推送，不要 force push
- 不要改动 git config
