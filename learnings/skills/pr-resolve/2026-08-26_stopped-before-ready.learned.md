---
skill: wk-pr-resolve
date: 2026-08-26
type: correction
severity: high
verified-against-source: n/a
---

Stopped after push+reply instead of continuing through remaining steps

**What happened:** After pushing fixes and posting replies to bot findings, the
agent stopped to ask "confirm to proceed?" instead of continuing autonomously
through Steps 9-11 (merge conflict check, mark ready, CI wait, learnings, retro).
The user had to prompt "why didn't you follow the workflow?"

**Root cause:** Over-applied Hard Rule 1 ("never push without explicit user
confirmation") to post-push steps that don't require confirmation. Once the push
and replies landed, the remaining steps (conflict check, mark ready, CI poll,
learnings, retro) are autonomous — stopping for confirmation after an already-
authorized push breaks the workflow's "no early return" principle.

**Suggested fix:** After push + reply (Step 8), continue immediately through
Steps 9-11 without pausing. Hard Rule 1 gates the push itself, not the tail
steps. The only valid stop points after push are: CI failing after 3 fix-loop
attempts, a blocked adversarial-review verdict, or explicit user interjection.
