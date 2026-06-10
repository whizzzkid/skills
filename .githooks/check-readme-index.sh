#!/usr/bin/env bash
# check-readme-index.sh — keep both skill indexes in sync with the skills/ tree.
#
# Enforces AGENTS.md § README Maintenance "Root index rule": every skill
# directory must have a row in BOTH index files, and neither index may link to
# a skill directory that no longer exists.
#
#   - skills/README.md   (canonical owned index)   link form: [`wk-<name>`](./<name>/README.md)
#   - README.md          (root landing-page mirror) link form: [<name>](skills/<name>/)
#
# SCOPE: runs only when the staged set touches a skill's SKILL.md (added,
# modified, renamed, or DELETED) or either index file — so adding, removing, or
# updating a skill re-checks the indexes, while unrelated commits are skipped.
#
# `_template/` is excluded (it is a scaffold, not a published skill).

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

ROOT_INDEX="README.md"
SKILLS_INDEX="skills/README.md"

# Trigger only on relevant staged changes (include deletions: --diff-filter=ACMRD).
relevant=$(git diff --cached --name-only --diff-filter=ACMRD | perl -ne '
  print if m{^skills/[^/]+/SKILL\.md$} || m{^README\.md$} || m{^skills/README\.md$};
')
[[ -z "$relevant" ]] && exit 0

missing=()
orphans=()

# 1. Every skills/<name>/ dir (except _template) must be linked in both indexes.
for dir in skills/*/; do
  name="$(basename "$dir")"
  [[ "$name" == "_template" ]] && continue
  [[ -f "$dir/SKILL.md" ]] || continue

  grep -qF "(./$name/" "$SKILLS_INDEX" \
    || missing+=("  $name  — no row in $SKILLS_INDEX (expected a [...](./$name/README.md) link)")
  grep -qF "(skills/$name/" "$ROOT_INDEX" \
    || missing+=("  $name  — no row in $ROOT_INDEX (expected a [...](skills/$name/) link)")
done

# 2. Neither index may link to a skill directory that does not exist (orphan row).
while IFS= read -r name; do
  [[ -z "$name" ]] && continue
  [[ -d "skills/$name" ]] || orphans+=("  $name  — linked in $SKILLS_INDEX but skills/$name/ does not exist")
done < <(grep -oE '\(\./[a-z0-9][a-z0-9-]*/README\.md\)' "$SKILLS_INDEX" \
          | sed -E 's#\(\./##; s#/README\.md\)##' | sort -u)

while IFS= read -r name; do
  [[ -z "$name" ]] && continue
  [[ -d "skills/$name" ]] || orphans+=("  $name  — linked in $ROOT_INDEX but skills/$name/ does not exist")
done < <(grep -oE '\(skills/[a-z0-9][a-z0-9-]*/' "$ROOT_INDEX" \
          | sed -E 's#\(skills/##; s#/##' | sort -u)

if [[ ${#missing[@]} -gt 0 || ${#orphans[@]} -gt 0 ]]; then
  echo "✗ pre-commit: skill index out of sync with skills/ tree" >&2
  echo "" >&2
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Missing index rows:" >&2
    printf '%s\n' "${missing[@]}" >&2
  fi
  if [[ ${#orphans[@]} -gt 0 ]]; then
    echo "Orphan index rows (skill removed/renamed but row remains):" >&2
    printf '%s\n' "${orphans[@]}" >&2
  fi
  echo "" >&2
  echo "Fix: add/remove the row in both $ROOT_INDEX and $SKILLS_INDEX so each" >&2
  echo "matches the skills/ directory set, then re-stage. See wk-skill Step 6." >&2
  exit 1
fi

exit 0
