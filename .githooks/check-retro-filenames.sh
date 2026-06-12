#!/usr/bin/env bash
# check-retro-filenames.sh — enforce the retrospect-file naming convention:
#   every learnings/retrospect/*.md must be named
#   YYYY-MM-DD_<kebab-name>.md  (unprocessed, write-once per session)
#   or YYYY-MM-DD_<kebab-name>.learned.md  (distilled by wk-sharpen)
#
# Legacy per-day files (YYYY-MM-DD.md, no session slug) are grandfathered so
# pre-convention history stays committable.
#
# Runs as a lefthook pre-commit step. Exits non-zero to block the commit when
# any staged retrospect file is misnamed (wrong date format, non-kebab slug,
# or a stray suffix).

set -euo pipefail

# Staged files under learnings/retrospect/ ending in .md (added/copied/modified/renamed)
staged=$(git diff --cached --name-only --diff-filter=ACMR \
  | grep -E '^learnings/retrospect/.+\.md$' || true)

[[ -z "$staged" ]] && exit 0

# Canonical: 2026-06-12_session-1.md or 2026-06-12_session-1.learned.md
# Grandfathered legacy: 2026-06-12.md or 2026-06-12.learned.md (no slug)
pattern='^[0-9]{4}-[0-9]{2}-[0-9]{2}(_[a-z0-9-]+)?(\.learned)?\.md$'

violations=()
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  base="${f##*/}"
  if [[ ! "$base" =~ $pattern ]]; then
    violations+=("  $f")
  fi
done <<< "$staged"

if [[ ${#violations[@]} -gt 0 ]]; then
  echo "✗ pre-commit: retrospect file does not match YYYY-MM-DD_<name>[.learned].md" >&2
  echo "" >&2
  for v in "${violations[@]}"; do
    echo "$v" >&2
  done
  echo "" >&2
  echo "Fix: rename to <YYYY-MM-DD>_<kebab-name>.md" >&2
  echo "  - date prefix at the start, underscore separator" >&2
  echo "  - lowercase kebab slug (a-z, 0-9, hyphens), e.g. session-1" >&2
  echo "  - plain .md is an unprocessed session; .learned.md is distilled" >&2
  exit 1
fi

exit 0
