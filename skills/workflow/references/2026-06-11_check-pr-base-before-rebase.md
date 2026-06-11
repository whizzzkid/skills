---
class: principle
date: 2026-06-11
skill: wk-workflow
severity: high
---

- **Rule:** Resolve a PR's base via `gh pr view --json baseRefName --jq
  .baseRefName` before proposing or planning a rebase — not only at rework
  execution time. Never assume the default branch.
- **Why:** A branch with a non-default base (a stacked PR) gets a
  `<default>..HEAD` range and a rebase-onto-default proposal that is simply
  wrong; baseRefName is authoritative.
- **Where:** Phase 5 Pre-rework fetch HARD RULE — planning-time base
  resolution bullet.
