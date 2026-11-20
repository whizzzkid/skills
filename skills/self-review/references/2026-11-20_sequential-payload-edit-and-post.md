---
class: principle
skill: wk-self-review
date: 2026-11-20
---

# Payload edits and the review POST are sequential

- **Rule:** Make the last Edit/Write to the review payload in one turn, then POST in the next. Never send them as
  parallel calls in one batch.
- **Why:** An anchor-line fix to the payload and the `--input` POST went out together. It came out right only because
  the Edit happened to finish first; the agent then had to re-fetch the staged comments to confirm positions. The POST
  reads the file the Edit writes, so the two calls depend on each other.
- **Where:** `SKILL.md` → Step 4, next to the Write-tool-only payload rule.
