---
skill: wk-pr-resolve
date: 2026-05-29
type: correction
severity: high
---

Obvious-fix bot findings must be applied immediately without a confirmation prompt.

**What happened:** A bot flagged a regression (permission-error swallowed and treated as file-absent). The agent correctly classified it as obvious-fix with "no valid reason to skip," then still presented an `(a)/(e)/(d)/(s)` prompt and waited for user input. User explicitly corrected: "why are you confirming if there is no reason to skip? this should be auto-fixed."

**Root cause:** Recurring failure — this is the 5th capture (previous: 2026-04-27, 2026-04-30 x2, 2026-05-08). The skill instructions say obvious-fix items go to the bulk-queue without per-item consultation, but the agent pattern-matches "bot finding + severity" and routes to consultation regardless of the skip rationale.

**Suggested fix:** Add an explicit pre-prompt check: before emitting ANY `(a)/(e)/(d)/(s)` prompt, re-read the "Why this could be skipped" rationale. If it contains "no valid reason," "no good reason," or is empty — STOP, do not emit the prompt, apply directly. The check must fire even for bot findings marked Major/blocker severity. Severity is not a bypass for the obvious-fix rule.
