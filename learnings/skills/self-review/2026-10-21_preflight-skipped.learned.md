---
skill: wk-self-review
date: 2026-10-21
type: gap
severity: low
verified-against-source: n/a
---

Pending-review POST was denied by the auto-mode classifier after the payload was already written.

**What happened:** Step 0.5's permission preflight was skipped; the denial surfaced only at Step 4.

**Root cause:** The preflight reads as optional when running in auto mode.

**Suggested fix:** Make Step 0.5 a HARD RULE gate in auto mode: no matching allow rule → write the payload, then hand the user the one-liner without attempting the POST.
