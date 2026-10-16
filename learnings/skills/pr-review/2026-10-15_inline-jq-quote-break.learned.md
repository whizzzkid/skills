---
skill: wk-pr-review
date: 2026-10-15
type: correction
severity: low
verified-against-source: n/a
---

Building the review payload with an inline single-quoted jq program broke when a comment body contained an apostrophe.

**What happened:** The payload was built with `jq -n '...'` in Bash; an apostrophe ("won't") inside a body string ended the shell quote early and the command failed.

**Root cause:** The skill already says to write the payload with the Write tool, but the agent ignored that and built it inline.

**Suggested fix:** Repeat in Phase 5 that prose comment bodies must never be built inside a single-quoted shell string; use the Write tool every time.
