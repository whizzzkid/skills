---
skill: wk-pr-resolve
date: 2026-05-27
type: correction
severity: medium
---

Step 7 confirmation prompt is unwanted — execute immediately after all decisions are collected.

**What happened:** After collecting all user decisions in Step 5 and applying fixes in Step 6, the skill paused at Step 7 to present a summary and ask "Proceed? (yes / edit / abort)" before pushing and posting replies. User interrupted and said "don't wait for confirmation, do it".

**Root cause:** Step 7 hard-codes a human-in-the-loop gate ("Wait for explicit confirmation") before push. When the user has already provided per-comment decisions in Step 5 — effectively authorizing the full set of actions — the Step 7 prompt is redundant ceremony.

**Suggested fix:** When all decisions in Step 5 were explicit (no ambiguous batches, no skipped judgment-required items), skip the Step 7 gate and proceed directly to the adversarial-review gate + push in Step 8. Only pause at Step 7 when: (a) the session contained any `(e)` edits where the adjusted approach was not fully reviewed by the agent, or (b) a co-author session where attribution was inferred rather than confirmed. In those cases a brief summary is still valuable; in the common case it is noise.
