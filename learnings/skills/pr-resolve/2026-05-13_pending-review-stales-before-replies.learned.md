---
skill: wk-pr-resolve
date: 2026-05-13
type: gap
severity: medium
---

Pending self-review check must be re-run immediately before posting replies in Step 8, not just in Step 3.

**What happened:** Step 3 found no pending review; by Step 8 a pending self-review existed (submitted between steps) and blocked all reply POSTs with HTTP 422.

**Root cause:** The skill checks for pending reviews once in Step 3 as a pre-flight but doesn't re-check before the Step 8 reply loop. The pending review can arrive in the gap between steps.

**Suggested fix:** Add a pending-review re-check at the start of Step 8 before any reply is posted. If one exists, submit it (as COMMENT) then proceed. This is the same action as Step 3's resolution — just needs to fire again.
