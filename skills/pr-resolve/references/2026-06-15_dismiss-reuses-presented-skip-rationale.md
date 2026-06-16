---
class: principle
date: 2026-06-15
---

# Dismissal reuses the skip rationale already presented

**Rule:** On a `d` Dismiss decision, reuse the `Why skip` rationale the agent
already presented for that comment in Step 4 as the dismissal reason — do not
re-ask the user "why". Prompt only when that rationale is empty / "No valid
reason to skip", or to let the user edit it.

**Why:** Step 4's suggestion format already requires the agent to state why a
comment can be dismissed. Re-asking duplicates that work and adds a needless
round-trip; the presented rationale is the dismissal reason.

**Where:** Step 5 → Decision handling → `d` Dismiss, and the consultation prompt
`(d)` option.
