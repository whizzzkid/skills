---
skill: wk-sharpen
date: 2026-07-17
type: correction
severity: medium
---

Explicit skill invocation already IS approval — do not re-ask before applying.

**What happened:** After distilling the batch and drafting the fold plan, the
agent presented the diff and asked "Approve and I'll apply + commit?" The user
replied "why do you need my approval?" — the invocation was the go-ahead; the
second confirmation gate was pure friction.

**Root cause:** Step 6 "Present for Review / Wait for approval" reads as an
unconditional stop-and-ask gate. When the user directly ran `/wk-sharpen` (or the
skill was invoked in auto mode), that invocation is the standing consent to apply
the distilled folds; a second explicit confirmation duplicates it.

**Suggested fix:** In Step 6, treat a direct `/wk-sharpen` invocation (and auto
mode) as satisfying the approval gate — proceed straight to apply/commit/push
without a second confirmation. Reserve an explicit ask only for genuinely
ambiguous scope (e.g. `wk-learn` vs `wk-sharpen` routing) or a destructive/
irreversible action, not for routine fold application.
