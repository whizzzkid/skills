#!/usr/bin/env bash
# PreToolUse hook: check env-vars declared in a skill's frontmatter before execution.
# Reads the Skill tool's JSON input from stdin; emits warnings to stderr (visible to Claude).
# Never exits non-zero — this hook warns but never blocks skill execution.

set -uo pipefail

SKILLS_HOME="${WK_SKILLS_HOME:-}"
PROFILE="$HOME/.profile"

# -- Read and parse tool input ------------------------------------------------
INPUT=$(cat 2>/dev/null) || { exit 0; }
SKILL_NAME=$(printf '%s' "$INPUT" \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('skill',''))" \
  2>/dev/null) || { exit 0; }
[ -z "$SKILL_NAME" ] && exit 0

# -- Resolve skill directory (strip wk- prefix) --------------------------------
DIR_NAME="${SKILL_NAME#wk-}"
[ -z "$SKILLS_HOME" ] && exit 0
SKILL_FILE="$SKILLS_HOME/skills/$DIR_NAME/SKILL.md"
[ -f "$SKILL_FILE" ] || exit 0

# -- Extract env-vars from frontmatter ----------------------------------------
# Parses the YAML frontmatter between the two --- markers.
ENV_VARS=$(awk '
  /^---/ { n++; next }
  n == 1 && /^env-vars:/ { found = 1; next }
  found && /^  - / { gsub(/^  - /, ""); print; next }
  found && !/^  - / { exit }
' "$SKILL_FILE" 2>/dev/null)

# Nothing declared — nothing to check.
[ -z "$ENV_VARS" ] && exit 0

# -- Check each var -----------------------------------------------------------
MISSING=()
EMPTY=()

while IFS= read -r var; do
  [ -z "$var" ] && continue
  # Skip names that are not valid shell identifiers — defends the indirect
  # expansion (${!var}) and the `bash -c` lookup below against a malformed
  # frontmatter entry.
  case "$var" in [!A-Za-z_]* | *[!A-Za-z0-9_]*) continue ;; esac
  if [ -z "${!var+x}" ] 2>/dev/null; then
    # Truly unset
    MISSING+=("$var")
  elif [ -z "${!var}" ]; then
    EMPTY+=("$var")
  fi
done <<< "$ENV_VARS"

[ ${#MISSING[@]} -eq 0 ] && [ ${#EMPTY[@]} -eq 0 ] && exit 0

# -- Source $HOME/.profile in subprocess and re-check -------------------------
RESOLVED=()
STILL_MISSING=()

# Combine both lists; ${ARR[@]+...} guards empty-array expansion under `set -u`
# (bash 3.2 on macOS treats "${EMPTY[@]}" on an empty array as unbound).
for var in ${MISSING[@]+"${MISSING[@]}"} ${EMPTY[@]+"${EMPTY[@]}"}; do
  val=$(bash -c "source '$PROFILE' 2>/dev/null; printf '%s' \"\${${var}:-}\"" 2>/dev/null || true)
  if [ -n "$val" ]; then
    RESOLVED+=("$var")
  else
    STILL_MISSING+=("$var")
  fi
done

# -- Emit warning -------------------------------------------------------------
{
  echo "┌─ wk-env: env check for skill '$SKILL_NAME'"

  if [ ${#RESOLVED[@]} -gt 0 ]; then
    echo "│  ⚠️  Resolved after sourcing $PROFILE (restart Claude Code from a login shell):"
    for v in "${RESOLVED[@]}"; do
      echo "│     – $v"
    done
  fi

  if [ ${#STILL_MISSING[@]} -gt 0 ]; then
    echo "│  ❌ Still missing after sourcing $PROFILE (add to $PROFILE):"
    for v in "${STILL_MISSING[@]}"; do
      echo "│     – export $v=<value>"
    done
  fi

  echo "└─ run \`/wk-env $SKILL_NAME\` for the full diagnostic"
} >&2

exit 0
