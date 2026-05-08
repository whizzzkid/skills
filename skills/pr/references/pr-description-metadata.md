---
title: PR description metadata preservation
---

**HARD RULE:** Before overwriting any PR description, preserve these metadata lines verbatim:

- `Closes #N` / `Fixes #N` / `Resolves #N` / `Refs #N` — these auto-close or link issues on merge; dropping them silently leaves linked issues open after merge
- `Co-authored-by:` trailers — attribution for contributors; dropping them erases credit
- Automation-generated blocks: `**Build:** [...]` links, `<details>` context sections, generator footer lines
- Any line that begins with a recognized keyword the PR system or CI bot owns

**Why this matters:** `gh pr edit --body-file` and `gh pr edit --body` replace the entire body with no merge. There is no recovery path — silently dropping `Closes #N` means the linked issue stays open after merge; dropping `Co-authored-by:` erases contributor attribution from the GitHub commit graph.

**How to preserve:**

```bash
# Read current body before any edit
CURRENT_BODY=$(gh pr view {number} --json body --jq .body)

# Extract metadata lines
CLOSES=$(echo "$CURRENT_BODY" | grep -E '^(Closes|Fixes|Resolves|Refs) #')
COAUTHORS=$(echo "$CURRENT_BODY" | grep -iE '^Co-authored-by:')
BUILD_BLOCK=$(echo "$CURRENT_BODY" | grep -E '^\*\*Build:')
DETAILS=$(echo "$CURRENT_BODY" | sed -n '/<details>/,/<\/details>/p')

# Re-insert metadata lines at the end of the new body
```

**Scope:** This rule applies to every skill that writes a PR description:
- `wk-pr` — Step 3 post-creation description update
- `wk-pr-resolve` — Step 8 post-push description sync
- `wk-pr-update` — Stage 6 PR sync after integration

**Exception:** Test-plan checkboxes ticked by a human reviewer are also in this category — do not overwrite them. Preserve their checked state verbatim.
