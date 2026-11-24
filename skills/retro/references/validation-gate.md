# Retro validation gate

Compose the bullets into the heredoc below, then run the whole block as **one** Bash call. It computes N, validates
the draft, and writes the session file — nothing crosses a tool-call boundary.

```bash
set -euo pipefail
DIR="$WK_SKILLS_HOME/learnings/retrospect"; DAY=$(date -u +%F); mkdir -p "$DIR"
# N = highest existing index today (processed or not) + 1. Never a file count (gaps collide), never hand-typed.
LAST=$(ls "$DIR" | sed -nE "s/^${DAY}_session-([0-9]+)(\.learned)?\.md$/\1/p" | sort -n | tail -1)
N=$(( ${LAST:-0} + 1 ))
FILE="$DIR/${DAY}_session-${N}.md"
# Per-run scratch: unique to this call, so concurrent sessions never share a draft.
WORK=$(mktemp -d "${TMPDIR:-/tmp}/wkretro.XXXXXX"); trap 'rm -rf "$WORK"' EXIT
DRAFT="$WORK/draft.md"
printf '## Session-%s\n\n' "$N" > "$DRAFT"
cat >> "$DRAFT" <<'EOF'
### What worked
- [pattern worth reinforcing as a rule]

### What could've been better
- [skill-name]: [one-sentence actionable gap]
EOF
# Guard: an empty draft passes every grep below silently — fail loudly instead.
[[ -s "$DRAFT" ]] || { echo "FAIL: draft is empty — refusing to write a blank retro entry"; exit 1; }
printf '%s\n%s\n' "$(printenv EMPLOYER || true)" "$(printenv GITHUB_ORG || true)" \
  | { grep -v '^$' || true; } > "$WORK/deny.txt"
if [[ -s "$WORK/deny.txt" ]] && grep -iF -f "$WORK/deny.txt" "$DRAFT"; then
  echo "FAIL: forbidden employer/org token in draft"; exit 1
fi
# user-land absolute paths (home dir / worktree) must be anonymized
if grep -nE '(/[U]sers/|/[h]ome/)[a-z._-]+/|'"$HOME"'/' "$DRAFT"; then
  echo "FAIL: user-land absolute path in draft — anonymize to repo-relative or /tmp/agent/…"; exit 1
fi
# no time-of-day stamps — the header is Session-N, not a clock time
if grep -nE '\b[0-9]{1,2}:[0-9]{2}\b|UTC' "$DRAFT"; then
  echo "FAIL: timestamp in retro entry — use 'Session-N', not a time of day"; exit 1
fi
# Write-once: refuse either form of the target; noclobber fails the redirect instead of replacing a racing write.
if [[ -e "$FILE" || -e "${FILE%.md}.learned.md" ]]; then
  echo "FAIL: $FILE exists — refusing to overwrite another session's file"; exit 1
fi
( set -C; cat "$DRAFT" > "$FILE" )
echo "wrote $FILE"
```

- Omit an empty bucket from the heredoc; both empty → do not run the block (Step 3 writes nothing).
- The quoted `'EOF'` keeps `$`, backticks, and quotes in bullets literal.
- Verified on bash and zsh: a gap in existing indices yields max+1, the noclobber redirect fails with rc 1 and leaves
  the existing file intact, and a failing check exits before any write.
