---
class: principle
skill: wk-pr-review
date: 2026-05-29
---

# Doc-only review: arithmetic audit + local-path-as-blocker

- **Rule:** In the doc-only Phase 4 substitute, run two explicit passes —
  cross-check every numeric/enumerated claim against the items actually counted,
  and flag any committed machine-local absolute path (username, home dir,
  worktree/workspace, local-only file/branch) as **blocker**.
- **Why:** A spec carried a stale "all six" count after a section split, and
  machine-specific worktree paths were filed as `suggestion` nits — but a path
  that resolves on one machine is broken for every other reader and leaks
  personal environment structure.
- **Where:** Phase 4 — Documentation-only diff substitute checklist.
- **Sources:** distilled from two learnings (`spec-arithmetic-and-local-path-audit`,
  `personal-artifacts-in-committed-docs`).
