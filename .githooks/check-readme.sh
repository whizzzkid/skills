#!/usr/bin/env bash
# check-readme.sh — enforce CLAUDE.md Rule 1:
#   every new or modified skills/*/SKILL.md must have a sibling README.md.
#
# Runs as a lefthook pre-commit step. Exits non-zero to block the commit
# if any staged SKILL.md is missing its README.md.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"

# Collect staged SKILL.md files that match skills/<name>/SKILL.md
staged_skills=$(git diff --cached --name-only --diff-filter=ACMR \
  | perl -ne 'print if m{^skills/[^/]+/SKILL\.md$}')

[[ -z "$staged_skills" ]] && exit 0

violations=()
while IFS= read -r skill_file; do
  skill_dir="${skill_file%/SKILL.md}"
  readme="$skill_dir/README.md"
  # README is acceptable if it exists on disk (staged or already committed).
  if [[ ! -f "$REPO_ROOT/$readme" ]]; then
    violations+=("  $skill_file  (missing $readme)")
  fi
done <<< "$staged_skills"

if [[ ${#violations[@]} -gt 0 ]]; then
  echo "✗ pre-commit: SKILL.md without a sibling README.md" >&2
  echo "" >&2
  for v in "${violations[@]}"; do
    echo "$v" >&2
  done
  echo "" >&2
  echo "Fix: create $readme following the template in skills/README.md," >&2
  echo "then stage it alongside the SKILL.md change." >&2
  exit 1
fi

exit 0
