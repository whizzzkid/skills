#!/usr/bin/env bash
# check-learnings-dirs.sh — enforce learnings/skills/ directory naming:
#   directories under learnings/skills/ must match the unprefixed skill dir
#   name in skills/ — never carry the `wk-` prefix (the prefix lives only in
#   the SKILL.md `name:` field).
#
# Root-cause guard for the wk-learn bug where a caller passing the full skill
# name (wk-workflow) created learnings/skills/wk-workflow/ instead of
# learnings/skills/workflow/.
#
# Runs as a lefthook pre-commit step. Exits non-zero to block the commit if any
# staged path lands under a wk-prefixed learnings directory.

set -euo pipefail

# Staged paths under a wk-prefixed learnings/skills/ directory.
violations=$(git diff --cached --name-only --diff-filter=ACMR \
  | perl -ne 'print if m{^learnings/skills/wk-[^/]+/}')

[[ -z "$violations" ]] && exit 0

echo "✗ pre-commit: wk-prefixed directory under learnings/skills/" >&2
echo "" >&2
# Show the offending top-level dirs, de-duplicated.
echo "$violations" | sed -E 's#^(learnings/skills/wk-[^/]+)/.*#  \1#' | sort -u >&2
echo "" >&2
echo "Fix: learnings dirs must match the unprefixed skills/ dir name." >&2
echo "Move into the unprefixed dir, e.g.:" >&2
echo "  git mv learnings/skills/wk-workflow/* learnings/skills/workflow/" >&2
echo "Root cause lives in wk-learn Step 3 — it strips the wk- prefix." >&2
exit 1
