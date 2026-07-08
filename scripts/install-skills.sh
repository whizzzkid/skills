#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Clear previously-installed wk-* skills before reinstalling. Deprecated skills
# are never auto-removed from the global dir, so they linger forever otherwise.
# Scoped to the wk-* glob to preserve siblings like learnings/ and non-wk skills.
GLOBAL_SKILLS_DIR="${HOME}/.claude/skills"
if [[ -d "$GLOBAL_SKILLS_DIR" ]]; then
  for skill_dir in "$GLOBAL_SKILLS_DIR"/wk-*; do
    [[ -d "$skill_dir" ]] || continue
    rm -rf "$skill_dir"
  done
fi

npx skills add . -g -y -a=claude

# Wire the skill-shipped hooks into $HOME/.claude/settings.json (idempotent).
"$(dirname "$0")/register-hooks.sh"
