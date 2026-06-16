#!/usr/bin/env bash
# check-skill-size.sh — enforce structural size ceilings on staged SKILL.md files.
#
# A SKILL.md is runtime instruction the agent loads in full on every invocation.
# Bloat (repeated rationale, verbose prose, redundant examples) accretes across
# sharpening passes and silently buries load-bearing rules. This hook blocks any
# staged SKILL.md that breaches one of four ceilings, forcing a de-bloat:
# bulletize, split into references/sub-skills, or scope the skill down — never by
# dropping a HARD RULE, error code, or failure-mode.
#
# Ceilings (each tunable via env without editing the hook):
#   - Body (everything after the YAML front-matter)  <= 24 KiB  SKILL_SIZE_MAX_BYTES
#   - Front-matter block (the `---` ... `---` header) <=  8 KiB  SKILL_FRONTMATTER_MAX_BYTES
#   - `description:` field                            <=  1 KiB  SKILL_DESC_MAX_BYTES
#   - `allowed-tools:` list                           <= 36 ln   SKILL_TOOLS_MAX_LINES
#
# Measures the STAGED blob (what is actually being committed), not the working
# tree, so a partially-staged edit is judged on its committed bytes.
#
# Override for a single commit (deliberate, reviewed exception):
#   SKILL_SIZE_MAX_BYTES=<n> git commit ...

set -euo pipefail

BODY_MAX_BYTES="${SKILL_SIZE_MAX_BYTES:-24576}"
FRONTMATTER_MAX_BYTES="${SKILL_FRONTMATTER_MAX_BYTES:-8192}"
DESC_MAX_BYTES="${SKILL_DESC_MAX_BYTES:-1024}"
TOOLS_MAX_LINES="${SKILL_TOOLS_MAX_LINES:-36}"

staged_skills=$(git diff --cached --name-only --diff-filter=ACMR \
  | { grep -E '(^|/)SKILL\.md$' || true; })

[[ -z "$staged_skills" ]] && exit 0

# Parse one staged SKILL.md blob into: <fm_bytes> <body_bytes> <desc_bytes> <tools_lines>.
# Byte-accurate under LC_ALL=C (length() counts bytes). Front-matter is the first
# `---` ... `---` block; `description:` and `allowed-tools:` blocks run until the
# next column-0 key.
measure() {
  git show ":$1" | LC_ALL=C awk '
    BEGIN { fm=0; body=0; desc=0; tools=0; state="pre"; indesc=0; intools=0 }
    {
      n = length($0) + 1
      if (state == "pre") {
        if ($0 == "---") { state="fm"; fm += n }
        else            { state="body"; body += n }
        next
      }
      if (state == "fm") {
        fm += n
        if ($0 == "---") { state="body"; indesc=0; intools=0; next }
        if ($0 ~ /^[A-Za-z_][A-Za-z0-9_-]*:/) { indesc=0; intools=0 }
        if ($0 ~ /^description:/)   { indesc=1; desc += n; next }
        if ($0 ~ /^allowed-tools:/) { intools=1; next }
        if (indesc)  { desc += n; next }
        if (intools) { if ($0 ~ /^[[:space:]]+-/) tools++; next }
        next
      }
      body += n
    }
    END { print fm, body, desc, tools }
  '
}

violations=()
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  read -r fm_bytes body_bytes desc_bytes tools_lines < <(measure "$f")

  if (( body_bytes > BODY_MAX_BYTES )); then
    violations+=("  $f: body $(printf '%.1fk' "$(echo "scale=1; $body_bytes/1024" | bc)") > $(( BODY_MAX_BYTES / 1024 ))k")
  fi
  if (( fm_bytes > FRONTMATTER_MAX_BYTES )); then
    violations+=("  $f: front-matter $(printf '%.1fk' "$(echo "scale=1; $fm_bytes/1024" | bc)") > $(( FRONTMATTER_MAX_BYTES / 1024 ))k")
  fi
  if (( desc_bytes > DESC_MAX_BYTES )); then
    violations+=("  $f: description $(printf '%.1fk' "$(echo "scale=1; $desc_bytes/1024" | bc)") > $(( DESC_MAX_BYTES / 1024 ))k")
  fi
  if (( tools_lines > TOOLS_MAX_LINES )); then
    violations+=("  $f: allowed-tools ${tools_lines} lines > ${TOOLS_MAX_LINES}")
  fi
done <<< "$staged_skills"

if (( ${#violations[@]} > 0 )); then
  echo "✗ pre-commit: SKILL.md exceeds a size ceiling" >&2
  echo "" >&2
  printf '%s\n' "${violations[@]}" >&2
  echo "" >&2
  echo "A SKILL.md is loaded in full on every invocation — oversized skills bury" >&2
  echo "load-bearing rules in fluff. Fix the offending skill before committing:" >&2
  echo "  - body: bulletize prose, cut repeated rationale (run wk-sharpen)" >&2
  echo "  - body: split detail into references/ or a focused sub-skill" >&2
  echo "  - front-matter / description: tighten the summary; trim metadata" >&2
  echo "  - allowed-tools: consolidate or narrow the tool list" >&2
  echo "Never drop a HARD RULE, error code, or failure-mode to fit a ceiling." >&2
  echo "" >&2
  echo "Deliberate exception: SKILL_SIZE_MAX_BYTES=<n> git commit ..." >&2
  exit 1
fi

exit 0
