#!/usr/bin/env bash
set -euo pipefail

# Fork-local companion to link-skills.sh (which is upstream-owned and must not
# be modified). Links the shared agent-role definitions into each harness's
# user-level agents directory, so the roles named by the skills (implementer,
# reviewer) resolve in every project:
#   - .claude/agents/*.md     -> ~/.claude/agents/          (Claude Code)
#   - .codex/agents/*.toml    -> ~/.codex/agents/           (Codex)
#   - .opencode/agents/*.md   -> ~/.config/opencode/agents/ (OpenCode)
# Each entry is a symlink into this repo, so a `git pull` keeps installed
# roles current. Re-run after adding, removing, or renaming a role.

REPO="$(cd "$(dirname "$0")/.." && pwd)"

link_dir() {
  local src_dir="$1" dest_dir="$2" pattern="$3"

  [ -d "$src_dir" ] || return 0
  mkdir -p "$dest_dir"

  local src target
  for src in "$src_dir"/$pattern; do
    [ -e "$src" ] || continue
    target="$dest_dir/$(basename "$src")"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "skip $target — exists and is not a symlink; remove it manually to adopt the repo version" >&2
      continue
    fi
    ln -sfn "$src" "$target"
    echo "linked $(basename "$src") -> $src ($dest_dir)"
  done
}

link_dir "$REPO/.claude/agents"   "$HOME/.claude/agents"          "*.md"
link_dir "$REPO/.codex/agents"    "$HOME/.codex/agents"           "*.toml"
link_dir "$REPO/.opencode/agents" "$HOME/.config/opencode/agents" "*.md"
