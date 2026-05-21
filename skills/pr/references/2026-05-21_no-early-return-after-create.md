---
name: no-early-return-after-create
description: PR creation is the midpoint of wk-pr, not the terminus — continue through Steps 3–5.
class: principle
---

- **Rule:** After `gh pr create` succeeds, proceed immediately to
  Step 3 (description sync, CI poll) without returning control.
  Continue through self-review, feedback triage, and `gh pr ready`
  on the same invocation.
- **Why:** Treating PR creation as the terminal action skips CI
  polling, self-review, automated feedback triage, and the
  ready-mark — the user expects the full lifecycle on one
  invocation. Early return fragments the workflow and forces the
  user to re-invoke for routine follow-up.
- **Where:** Step 3 opening HARD RULE — "no early return after
  `gh pr create`" — enumerating the only valid stopping points
  (CI failure after 3 fix attempts, blocked adversarial verdict,
  explicit user interjection).
