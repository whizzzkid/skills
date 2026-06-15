#!/usr/bin/env bash
# check-skill-size.sh — enforce a hard size ceiling on SKILL.md bodies.
#
# A SKILL.md is runtime instruction the agent loads in full on every
# invocation. Bloat (repeated rationale, verbose prose, redundant examples)
# accretes across sharpening passes and silently buries load-bearing rules.
# This hook blocks any staged SKILL.md whose committed size exceeds the
# ceiling, forcing a de-bloat: refactor, split into references/sub-skills,
# or scope the skill down — never by dropping a HARD RULE or failure-mode.
#
# Measures the STAGED blob (what is actually being committed), not the
# working tree, so a partially-staged edit is judged on its committed bytes.
#
# Override for a single commit (e.g. a deliberate, reviewed exception):
#   SKILL_SIZE_MAX_BYTES=<n> git commit ...

set -euo pipefail

# 24 KiB. Tune via env without editing the hook.
MAX_BYTES="${SKILL_SIZE_MAX_BYTES:-24576}"

staged_skills=$(git diff --cached --name-only --diff-filter=ACMR \
  | { grep -E '(^|/)SKILL\.md$' || true; })

[[ -z "$staged_skills" ]] && exit 0

violations=()
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  size=$(git cat-file -s ":$f" 2>/dev/null || echo 0)
  if (( size > MAX_BYTES )); then
    violations+=("  $(printf '%6.1fk' "$(echo "scale=1; $size/1024" | bc)")  $f")
  fi
done <<< "$staged_skills"

if (( ${#violations[@]} > 0 )); then
  echo "✗ pre-commit: SKILL.md exceeds the $(( MAX_BYTES / 1024 ))k size ceiling" >&2
  echo "" >&2
  printf '%s\n' "${violations[@]}" >&2
  echo "" >&2
  echo "A SKILL.md is loaded in full on every invocation — oversized skills bury" >&2
  echo "load-bearing rules in fluff. De-bloat the offending skill before committing:" >&2
  echo "  - refactor: cut repeated rationale and verbose prose (run wk-sharpen)" >&2
  echo "  - split: move detail into references/ or a focused sub-skill" >&2
  echo "  - scope down: narrow what the skill covers" >&2
  echo "Never drop a HARD RULE, error code, or failure-mode to fit the ceiling." >&2
  echo "" >&2
  echo "Deliberate exception: SKILL_SIZE_MAX_BYTES=<n> git commit ..." >&2
  exit 1
fi

exit 0
