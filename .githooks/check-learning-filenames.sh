#!/usr/bin/env bash
# check-learning-filenames.sh — enforce the learning-file naming convention:
#   every learnings/skills/<skill>/*.md must be named
#   YYYY-MM-DD_<kebab-name>.learned.md
#
# Runs as a lefthook pre-commit step. Exits non-zero to block the commit
# when any staged learning file is misnamed (wrong date format, missing
# date prefix, non-kebab name, or missing the .learned.md suffix).

set -euo pipefail

# Staged files under learnings/skills/ ending in .md (added/copied/modified/renamed)
staged=$(git diff --cached --name-only --diff-filter=ACMR \
  | grep -E '^learnings/skills/.+\.md$' || true)

[[ -z "$staged" ]] && exit 0

# Canonical pattern: 2026-06-11_some-kebab-name.learned.md
pattern='^[0-9]{4}-[0-9]{2}-[0-9]{2}_[a-z0-9-]+\.learned\.md$'

violations=()
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  base="${f##*/}"
  if [[ ! "$base" =~ $pattern ]]; then
    violations+=("  $f")
  fi
done <<< "$staged"

if [[ ${#violations[@]} -gt 0 ]]; then
  echo "✗ pre-commit: learning file does not match YYYY-MM-DD_<name>.learned.md" >&2
  echo "" >&2
  for v in "${violations[@]}"; do
    echo "$v" >&2
  done
  echo "" >&2
  echo "Fix: rename to <YYYY-MM-DD>_<kebab-name>.learned.md" >&2
  echo "  - date prefix at the start, underscore separator" >&2
  echo "  - lowercase kebab name (a-z, 0-9, hyphens)" >&2
  echo "  - .learned.md suffix (distilled) — a plain .md is unprocessed" >&2
  exit 1
fi

exit 0
