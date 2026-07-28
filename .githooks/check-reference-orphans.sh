#!/usr/bin/env bash
# check-reference-orphans.sh — reverse link check for skills/*/references/.
#
# check-links.sh and check-skill-links.sh validate the FORWARD direction (every
# link resolves) and both put references/ explicitly OUT of scope. Neither can
# see the opposite failure: a pointer SKILL.md used to carry is dropped — by a
# de-bloat pass reclaiming bytes, or by a relocation whose pointer is never
# written — while the target file survives. The relocated content is then
# unreachable at runtime and nothing fails, because the broken thing is the
# ABSENCE of a link, not a link to a missing file.
#
# Per-learning distillation records are unlinked BY DESIGN (SKILL.md Step 7:
# "Never link a per-learning reference from SKILL.md"), and neither filename
# shape nor the `class:` field distinguishes one from relocated runtime content
# — `class:` types the lesson (principle / one-off), not the file's role. So a
# whole-directory reachability sweep is not available: it would be almost
# entirely false positives.
#
# The check is therefore DIFFERENTIAL, which needs no classification at all:
#   a reference HEAD's SKILL.md already pointed at must still be pointed at.
#
# A pointer may legitimately move — into another reference, or into the README —
# so any tracked file under the skill dir counts as carrying it. Only a file
# naming itself is ignored.
#
# Retiring a reference is still allowed: delete the file in the same commit as
# its pointer and the pair drops out together.
#
# Judged on staged blobs, so a partially-staged edit is checked on the bytes
# actually being committed.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

staged_skills=$(git diff --cached --name-only --diff-filter=ACMR \
  | { grep -E '^skills/[^/]+/SKILL\.md$' || true; })

[[ -z "$staged_skills" ]] && exit 0

REF_RE='references/[A-Za-z0-9._-]+\.md'

violations=()

while IFS= read -r skill_md; do
  [[ -z "$skill_md" ]] && continue
  skill_dir="${skill_md%/SKILL.md}"

  # A brand-new SKILL.md has no HEAD version to diff against — nothing to lose.
  git cat-file -e "HEAD:$skill_md" 2>/dev/null || continue

  head_refs=$(git show "HEAD:$skill_md" \
    | { grep -oE "$REF_RE" || true; } \
    | sed 's#^references/##' | LC_ALL=C sort -u)
  [[ -z "$head_refs" ]] && continue

  # Every references/* mention anywhere under the skill dir, in ONE pass over
  # the index. Drop self-mentions: a file naming itself proves no reachability.
  linked_now=$(git grep --cached -oE "$REF_RE" -- "$skill_dir" 2>/dev/null \
    | awk -F: -v dir="$skill_dir" '
        { path = $1; ref = $2; sub(/^references\//, "", ref)
          if (path != dir "/references/" ref) print ref }' \
    | LC_ALL=C sort -u || true)

  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue

    # Retired alongside its pointer (no longer in the index) → not an orphan.
    git cat-file -e ":$skill_dir/references/$ref" 2>/dev/null || continue

    LC_ALL=C grep -Fxq "$ref" <<< "$linked_now" && continue
    violations+=("  $skill_dir/references/$ref — pointer dropped, file still tracked")
  done <<< "$head_refs"
done <<< "$staged_skills"

if (( ${#violations[@]} > 0 )); then
  echo "✗ pre-commit: orphaned reference — a pointer was dropped, its file kept" >&2
  echo "" >&2
  printf '%s\n' "${violations[@]}" >&2
  echo "" >&2
  echo "Relocated content is reachable at runtime only through its pointer." >&2
  echo "Fix one of:" >&2
  echo "  - restore the link in SKILL.md (or another file under the skill dir)" >&2
  echo "  - retire the reference: delete the file in this same commit" >&2
  exit 1
fi

exit 0
