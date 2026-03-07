#!/usr/bin/env bash
# 将 PostToolUse hook 注册到 ~/.claude/settings.json
# 安全 merge：不破坏现有配置

set -euo pipefail

SETTINGS_FILE="${HOME}/.claude/settings.json"
SKILL_SCRIPT="${HOME}/.claude/skills/skill-sync/scripts/sync.sh"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info() { echo -e "${GREEN}[skill-sync]${RESET} $*"; }
warn() { echo -e "${YELLOW}[skill-sync]${RESET} $*"; }

# 确保 settings.json 存在
if [[ ! -f "$SETTINGS_FILE" ]]; then
  echo '{}' > "$SETTINGS_FILE"
fi

python3 - "$SETTINGS_FILE" "$SKILL_SCRIPT" <<'PYTHON'
import sys
import json

settings_file = sys.argv[1]
skill_script = sys.argv[2]

with open(settings_file, 'r') as f:
    settings = json.load(f)

hook_entry = {
    "matcher": "Write",
    "hooks": [{
        "type": "command",
        "command": f"bash {skill_script} --detect-skill",
        "async": True
    }]
}

hooks = settings.setdefault("hooks", {})
post_tool_use = hooks.setdefault("PostToolUse", [])

# 检查是否已注册，避免重复
already_registered = any(
    h.get("matcher") == "Write" and
    any(
        hh.get("command", "").endswith("sync.sh --detect-skill")
        for hh in h.get("hooks", [])
    )
    for h in post_tool_use
)

if not already_registered:
    post_tool_use.append(hook_entry)
    with open(settings_file, 'w') as f:
        json.dump(settings, f, indent=2, ensure_ascii=False)
    print("OK: hook 已注册")
else:
    print("SKIP: hook 已存在，跳过")
PYTHON

info "PostToolUse hook 注册完成"
info "每次写入 SKILL.md 时将自动触发同步"
