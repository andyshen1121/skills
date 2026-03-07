---
description: 手动触发将所有 Claude Code skills 同步到 Codex 和 OpenClaw
---

运行 skill-sync 同步脚本，将 Claude Code 全局和项目级 skills 同步到 Codex 和 OpenClaw。

```bash
bash ~/.claude/skills/skill-sync/scripts/sync.sh
```

同步完成后，报告哪些 skill 已同步到哪些工具。如果脚本报错，向用户说明原因并给出修复建议。
