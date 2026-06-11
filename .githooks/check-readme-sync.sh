#!/usr/bin/env bash
# check-readme-sync.sh — enforce README/SKILL co-update:
#   every staged skills/*/SKILL.md must stage its sibling README.md in the
#   SAME commit, so the README (incl. its Version line) never drifts from
#   the SKILL.md it documents.
#
# Runs as a lefthook pre-commit step. Exits non-zero to block the commit
# when a SKILL.md is staged without its sibling README.md.
#
# Distinct from check-readme.sh: that one only requires the README to
# EXIST; this one requires it to be co-staged on every SKILL.md change.

set -euo pipefail

staged=$(git diff --cached --name-only --diff-filter=ACMR)

# Staged SKILL.md files matching skills/<name>/SKILL.md
staged_skills=$(printf '%s\n' "$staged" \
  | perl -ne 'print if m{^skills/[^/]+/SKILL\.md$}')

[[ -z "$staged_skills" ]] && exit 0

violations=()
while IFS= read -r skill_file; do
  [[ -z "$skill_file" ]] && continue
  readme="${skill_file%/SKILL.md}/README.md"
  # Pass only if the sibling README.md is also in the staged set.
  if ! printf '%s\n' "$staged" | grep -qxF "$readme"; then
    violations+=("  $skill_file  (stage $readme too)")
  fi
done <<< "$staged_skills"

if [[ ${#violations[@]} -gt 0 ]]; then
  echo "✗ pre-commit: SKILL.md changed without its README.md in the same commit" >&2
  echo "" >&2
  for v in "${violations[@]}"; do
    echo "$v" >&2
  done
  echo "" >&2
  echo "Fix: update the sibling README.md (bump its **Version:** line to match" >&2
  echo "metadata.version, sync any changed steps/diagram), then stage it." >&2
  exit 1
fi

exit 0
