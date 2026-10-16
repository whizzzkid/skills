---
class: principle
---

# Review payloads never pass through a single-quoted shell string

**Rule** — build the pending-review payload with the Write tool every time; never inline `jq -n '…'` or any
single-quoted shell string holding prose comment bodies.

**Why** — an apostrophe in a body ("won't") ends the shell quote early and the call fails. The Write-tool rule already
existed as baseline prose and was skipped, so this re-violation escalates it one rung: baseline → `**Important:**`.

**Where** — `SKILL.md` → Phase 5, bullet after the posting-reference pointer.
