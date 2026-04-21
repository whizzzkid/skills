---
skill: wk:pr-resolve
date: 2026-04-21
type: gap
severity: medium
---

Self-review threads with non-author replies are silently dropped, hiding real reviewer feedback.

**What happened:** On a PR, `{reviewer}` (human reviewer) replied inside a thread whose root comment was a self-review from the PR author. The current exclusion rule ("skip if root comment author == PR author") correctly skipped the thread for triage, but provided no signal to the user that a human reviewer's suggestion was living inside it. I had to notice it manually and flag it in the final summary; a less attentive run would have silently ignored legitimate feedback.

**Root cause:** Step 3 "Filter active comments" treats self-review threads as wholly excluded and emits no per-thread notice when non-author replies exist in them. The skill only separates threads into "human reviewer / bot / self-review" at the thread-root level.

**Suggested fix:** Add a sub-step to Step 3 and Step 10 summary: when excluding a self-review thread, scan its replies; if any are from users other than the PR author, emit in the final summary a "FYI — not triaged" note listing `{user}, {path}:{line}, {one-line body}` so the user can address them out-of-band. Do NOT triage, resolve, or fix — just surface.
