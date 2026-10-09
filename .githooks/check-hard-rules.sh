#!/usr/bin/env bash
# check-hard-rules.sh — block a commit that lowers a skill's HARD RULE count.
#
# A HARD RULE is a load-bearing, non-negotiable rule; de-bloat passes must never
# drop one. Compression tends to strip the label while "keeping the gist", which
# silently demotes the rule. This gate counts `HARD RULE` occurrences across a
# skill's SKILL.md + references/*.md in the STAGED tree vs HEAD, and blocks any
# decrease. Relocating a rule into references/ keeps the count, so extraction
# passes are unaffected.
#
# Deliberate merge of two rules into one (both constraints fully kept):
#   HARD_RULE_MERGE_OK=<skill>[,<skill>...] git commit ...

set -euo pipefail

staged=$(git diff --cached --name-only --diff-filter=ACMRD \
  | { grep -E '^skills/[^/]+/(SKILL\.md|references/.+\.md)$' || true; })

[[ -z "$staged" ]] && exit 0

skills=$(printf '%s\n' "$staged" | cut -d/ -f2 | sort -u)
allowed=",${HARD_RULE_MERGE_OK:-},"

# Count HARD RULE in a skill dir at a tree-ish ("" = index/staged, "HEAD" = last commit).
count_rules() {
  local rev="$1" skill="$2" paths
  if [[ -z "$rev" ]]; then
    paths=$(git ls-files -- "skills/$skill/SKILL.md" "skills/$skill/references/*.md")
  else
    paths=$(git ls-tree -r --name-only "$rev" -- "skills/$skill/SKILL.md" "skills/$skill/references/" 2>/dev/null \
      | { grep -E '\.md$' || true; })
  fi
  [[ -z "$paths" ]] && { echo 0; return; }
  local total=0 n path
  while IFS= read -r path; do
    n=$(git show "${rev}:${path}" 2>/dev/null | { grep -o 'HARD RULE' || true; } | wc -l)
    total=$(( total + n ))
  done <<< "$paths"
  echo "$total"
}

violations=()
while IFS= read -r skill; do
  [[ -z "$skill" ]] && continue
  git cat-file -e "HEAD:skills/$skill/SKILL.md" 2>/dev/null || continue  # new skill
  before=$(count_rules HEAD "$skill")
  after=$(count_rules "" "$skill")
  if (( after < before )) && [[ "$allowed" != *",$skill,"* ]]; then
    violations+=("  skills/$skill: HARD RULE $before -> $after")
  fi
done <<< "$skills"

if (( ${#violations[@]} > 0 )); then
  echo "✗ pre-commit: HARD RULE count decreased" >&2
  echo "" >&2
  printf '%s\n' "${violations[@]}" >&2
  echo "" >&2
  echo "De-bloat compresses wording, never the rule. Re-apply the" >&2
  echo "\`**HARD RULE — ...**\` label (or restore the dropped clause)." >&2
  echo "Deliberate merge of two rules: HARD_RULE_MERGE_OK=<skill> git commit ..." >&2
  exit 1
fi

exit 0
