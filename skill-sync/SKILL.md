---
name: skill-sync
description: 当用户提到"同步 skill"、"把 skill 同步到其他工具"、"sync skill to codex/openclaw"、"skill 同步"、"发布 skill"、"让其他 AI 工具也能用这个 skill"时触发。负责将 Claude Code skills 同步到 Codex 和 OpenClaw，处理各工具间的 frontmatter 格式差异。
---

# Skill Sync

将 Claude Code skills 自动同步到 Codex 和 OpenClaw，处理各工具的 frontmatter 格式差异。

## 同步规则

### Frontmatter 字段处理

| 字段 | Claude Code | Codex | OpenClaw |
|------|------------|-------|----------|
| `name` | 保留 | 保留 | 保留 |
| `description` | 保留 | 保留 | 保留 |
| `version` | 保留 | 移除 | 保留 |
| `license` | 保留 | 移除 | 保留 |
| `user-invocable` | 不支持 | 不支持 | 保留（缺失时补 `true`）|
| `disable-model-invocation` | 支持 | 移除 | 保留 |

- Codex：只保留 `name` + `description`，其余字段全部移除
- OpenClaw：保留所有字段，`user-invocable` 缺失时自动补 `true`
- skill 正文（frontmatter 以下内容）：原样复制，不做任何修改

## 执行同步

当用户要求同步时，运行同步脚本：

```bash
bash ~/.claude/skills/skill-sync/scripts/sync.sh
```

脚本会自动：
1. 检测 Codex 和 OpenClaw 是否已安装
2. 扫描 Claude Code 的全局和项目级 skill 目录
3. 转换 frontmatter 并复制到目标工具目录
4. 输出同步报告

## 目录位置

- Claude Code 全局：`~/.claude/skills/`
- Claude Code 项目级：`.claude/skills/`（当前工作目录）
- Codex：`~/.codex/skills/`
- OpenClaw：`~/.openclaw/skills/`
