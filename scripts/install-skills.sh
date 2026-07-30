#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

REGISTER_HOOKS_PATH="$(dirname "$0")/register-hooks.sh"

# Preflight first so a missing tool cannot erase the active installation.
command -v npx >/dev/null 2>&1 || {
  echo "install-skills: npx required" >&2
  exit 1
}
command -v python3 >/dev/null 2>&1 || {
  echo "install-skills: python3 required" >&2
  exit 1
}
[[ -x "$REGISTER_HOOKS_PATH" ]] || {
  echo "install-skills: hook registrar not executable: $REGISTER_HOOKS_PATH" >&2
  exit 1
}

npx -y skills add . -g -y --agent claude-code

# Remove deprecated wk-* skills only after the replacement install succeeds.
# Scoped to the wk-* glob to preserve siblings like learnings/ and non-wk skills.
GLOBAL_SKILLS_DIR="${HOME}/.claude/skills"
if [[ -d "$GLOBAL_SKILLS_DIR" ]]; then
  for skill_dir in "$GLOBAL_SKILLS_DIR"/wk-*; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="${skill_dir##*/}"
    is_current=false
    for skill_file in skills/*/SKILL.md; do
      [[ -f "$skill_file" ]] || continue
      if command grep -Fxq -- "name: $skill_name" "$skill_file"; then
        is_current=true
        break
      fi
    done
    [[ "$is_current" == true ]] || rm -rf "$skill_dir"
  done
fi

# Wire the skill-shipped hooks into $HOME/.claude/settings.json (idempotent).
"$REGISTER_HOOKS_PATH"
