---
class: principle
skill: wk-pr-resolve
date: 2026-05-29
---

# Severity is not a bypass for the obvious-fix no-prompt rule

- **Rule:** A bot/reviewer finding marked Major/blocker/critical with an empty
  "no valid reason" skip rationale is still `obvious-fix` — apply it directly,
  emit no `(a)/(e)/(d)/(s)` prompt. The rationale, not the severity, decides
  whether a prompt is owed.
- **Why:** Recurring failure (5th capture) — the agent pattern-matches "bot
  finding + high severity" and routes to consultation despite a rationale that
  concedes there is nothing to weigh, forcing a ceremony `a`.
- **Where:** Step 4 — appended to the "before emitting any consultation prompt"
  HARD RULE.
