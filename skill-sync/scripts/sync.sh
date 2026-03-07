#!/usr/bin/env bash
# skill-sync: 将 Claude Code skills 同步到 Codex 和 OpenClaw
# 用法:
#   sync.sh                  全量同步所有 skill
#   sync.sh --detect-skill   hook 模式：从 stdin 读取工具调用，仅当写入 SKILL.md 时触发同步

set -euo pipefail

# ── 颜色输出 ────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${GREEN}[skill-sync]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[skill-sync]${RESET} $*"; }
error()   { echo -e "${RED}[skill-sync]${RESET} $*" >&2; }

# ── Hook 检测模式 ────────────────────────────────────────────────
if [[ "${1:-}" == "--detect-skill" ]]; then
  # 从 stdin 读取 PostToolUse 的 JSON 输入
  input=$(cat)
  file_path=$(echo "$input" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    # PostToolUse 输入结构: {tool_name, tool_input: {file_path, ...}}
    fp = data.get('tool_input', {}).get('file_path', '')
    print(fp)
except:
    print('')
" 2>/dev/null <<< "$input")

  # 只有写入路径包含 skills/*/SKILL.md 才触发同步
  if [[ "$file_path" =~ skills/.+/SKILL\.md$ ]]; then
    info "检测到 SKILL.md 写入: $file_path，开始同步..."
    exec "$0"  # 重新执行自身做全量同步
  fi
  exit 0
fi

# ── 目录配置 ─────────────────────────────────────────────────────
CLAUDE_GLOBAL_DIR="${HOME}/.claude/skills"
CLAUDE_PROJECT_DIR="${PWD}/.claude/skills"
CODEX_DIR="${HOME}/.codex/skills"
OPENCLAW_DIR="${HOME}/.openclaw/skills"

# ── 检测目标工具 ──────────────────────────────────────────────────
detect_targets() {
  TARGETS=()
  if command -v codex &>/dev/null || [[ -d "$CODEX_DIR" ]]; then
    TARGETS+=("codex")
  fi
  if command -v openclaw &>/dev/null || [[ -d "$OPENCLAW_DIR" ]]; then
    TARGETS+=("openclaw")
  fi

  if [[ ${#TARGETS[@]} -eq 0 ]]; then
    warn "未检测到 Codex 或 OpenClaw，创建目录后继续同步..."
    mkdir -p "$CODEX_DIR" "$OPENCLAW_DIR"
    TARGETS=("codex" "openclaw")
  fi
}

# ── Frontmatter 转换 ──────────────────────────────────────────────
# 用法: convert_frontmatter <tool> <skill_file>
# 输出转换后的完整文件内容到 stdout
convert_frontmatter() {
  local tool="$1"
  local skill_file="$2"

  python3 - "$tool" "$skill_file" <<'PYTHON'
import sys
import re

tool = sys.argv[1]
skill_file = sys.argv[2]

with open(skill_file, 'r', encoding='utf-8') as f:
    content = f.read()

# 分离 frontmatter 和正文
fm_match = re.match(r'^---\n(.*?)\n---\n?(.*)', content, re.DOTALL)
if not fm_match:
    # 没有 frontmatter，原样输出
    sys.stdout.write(content)
    sys.exit(0)

fm_text = fm_match.group(1)
body = fm_match.group(2)

# 解析 frontmatter 为有序键值对（保持原始顺序，支持多行值）
lines = fm_text.split('\n')
fields = {}
order = []
current_key = None
current_val_lines = []

for line in lines:
    key_match = re.match(r'^(\S[^:]*?):\s*(.*)', line)
    if key_match:
        if current_key:
            fields[current_key] = '\n'.join(current_val_lines).strip()
        current_key = key_match.group(1).strip()
        current_val_lines = [key_match.group(2)]
        if current_key not in order:
            order.append(current_key)
    elif current_key and (line.startswith('  ') or line.startswith('\t')):
        current_val_lines.append(line)
    # 忽略空行和无效行

if current_key:
    fields[current_key] = '\n'.join(current_val_lines).strip()

# 按工具规则过滤/补充字段
if tool == 'codex':
    # Codex 只保留 name 和 description
    keep = ['name', 'description']
    new_order = [k for k in order if k in keep]
    new_fields = {k: fields[k] for k in new_order if k in fields}

elif tool == 'openclaw':
    # OpenClaw 保留全部字段，补全 user-invocable
    new_order = order[:]
    new_fields = dict(fields)
    if 'user-invocable' not in new_fields:
        new_fields['user-invocable'] = 'true'
        new_order.append('user-invocable')
    # 移除 Claude Code 不共享的字段
    for drop in ['version', 'license']:
        pass  # OpenClaw 支持这些，保留

else:
    new_order = order
    new_fields = fields

# 重建 frontmatter
fm_lines = ['---']
for key in new_order:
    if key in new_fields:
        val = new_fields[key]
        if '\n' in val:
            # 多行值用缩进格式
            fm_lines.append(f'{key}: |')
            for vl in val.split('\n'):
                fm_lines.append(f'  {vl}')
        else:
            fm_lines.append(f'{key}: {val}')
fm_lines.append('---')

output = '\n'.join(fm_lines) + '\n' + body
sys.stdout.write(output)
PYTHON
}

# ── 同步单个 skill ────────────────────────────────────────────────
sync_skill() {
  local skill_dir="$1"
  local skill_name
  skill_name=$(basename "$skill_dir")
  local skill_file="$skill_dir/SKILL.md"

  if [[ ! -f "$skill_file" ]]; then
    return 0
  fi

  local synced=0
  local errors=0

  for target in "${TARGETS[@]}"; do
    local target_dir
    case "$target" in
      codex)    target_dir="$CODEX_DIR/$skill_name" ;;
      openclaw) target_dir="$OPENCLAW_DIR/$skill_name" ;;
    esac

    mkdir -p "$target_dir"

    # 转换并写入 SKILL.md
    if convert_frontmatter "$target" "$skill_file" > "$target_dir/SKILL.md" 2>/dev/null; then
      # 同步其他资源文件（scripts/、references/、assets/），原样复制
      for subdir in scripts references assets; do
        if [[ -d "$skill_dir/$subdir" ]]; then
          cp -r "$skill_dir/$subdir" "$target_dir/"
        fi
      done
      ((synced++)) || true
    else
      error "转换失败: $skill_name -> $target"
      ((errors++)) || true
    fi
  done

  if [[ $errors -eq 0 ]]; then
    info "  $skill_name -> ${TARGETS[*]}"
  fi
}

# ── 扫描并同步所有 skill 目录 ─────────────────────────────────────
sync_all() {
  local total=0
  local sources=()

  [[ -d "$CLAUDE_GLOBAL_DIR" ]]  && sources+=("$CLAUDE_GLOBAL_DIR")
  [[ -d "$CLAUDE_PROJECT_DIR" ]] && sources+=("$CLAUDE_PROJECT_DIR")

  if [[ ${#sources[@]} -eq 0 ]]; then
    warn "未找到 Claude Code skill 目录，跳过同步"
    return 0
  fi

  for source_dir in "${sources[@]}"; do
    info "扫描: $source_dir"
    for skill_dir in "$source_dir"/*/; do
      [[ -d "$skill_dir" ]] || continue
      sync_skill "$skill_dir"
      ((total++)) || true
    done
  done

  info "完成：共同步 $total 个 skill 到 ${TARGETS[*]}"
}

# ── 主流程 ────────────────────────────────────────────────────────
main() {
  info "开始同步..."
  detect_targets
  sync_all
}

main
