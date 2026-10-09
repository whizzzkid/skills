# Retro validation gate

Run after composing the draft, before Write.

```bash
# Use a FIXED temp path, not $$ — each Bash tool call is a new subprocess,
# so $$ differs between the write call and a later read/sed call and the
# file is not found. A fixed slug survives across tool invocations.
DRAFT=/tmp/retro-draft-wkretro.md
# write the proposed entry to $DRAFT first
# Guard: an empty/unset $DRAFT appends nothing and passes every grep below
# silently — fail loudly instead of writing a blank entry.
[[ -s "$DRAFT" ]] || { echo "FAIL: draft is empty — refusing to append a blank retro entry"; exit 1; }
DENY="$(printenv EMPLOYER):$(printenv GITHUB_ORG)"
echo "$DENY" | tr ':' '\n' | grep -v '^$' > /tmp/retro-deny-wkretro.txt
if grep -iF -f /tmp/retro-deny-wkretro.txt "$DRAFT" 2>/dev/null; then
  echo "FAIL: forbidden employer/org token in draft"; exit 1
fi
# user-land absolute paths (home dir / worktree) must be anonymized
if grep -nE '(/[U]sers/|/[h]ome/)[a-z._-]+/|'"$HOME"'/' "$DRAFT" 2>/dev/null; then
  echo "FAIL: user-land absolute path in draft — anonymize to repo-relative or /tmp/agent/…"; exit 1
fi
# no time-of-day stamps — the header is Session-N, not a clock time
if grep -nE '\b[0-9]{1,2}:[0-9]{2}\b|UTC' "$DRAFT" 2>/dev/null; then
  echo "FAIL: timestamp in retro entry — use 'Session-N', not a time of day"; exit 1
fi
```
