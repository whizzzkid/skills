---
class: principle
date: 2026-06-12
skill: wk-pr-merge
---

- **Rule:** Always attempt `--squash` first on every merge; fall back only on
  non-zero exit. On failure, detect allowed methods and retry with the next
  best alternative in order `--rebase` then `--merge`.
- **Why:** Pre-selecting a method from repo settings can skip squash even
  when squash is allowed; squash gives the cleanest history and should be the
  unconditional default.
- **Where:** Step 6 Merge the PR — squash-first HARD RULE + fallback order.
