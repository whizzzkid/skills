---
class: principle
date: 2026-06-11
skill: wk-adversarial-review
---

- **Rule:** After a rebase, do not fold a fix into a mid-chain commit via
  `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <base>`; amend it into a
  standalone conventional commit instead.
- **Why:** `--autosquash <base>` replays the whole chain from `<base>`,
  re-exposing every already-resolved conflict — not an in-place squash.
- **Where:** Step 6 Fix Loop — artifact-rebuild-after-rebase caveat.
