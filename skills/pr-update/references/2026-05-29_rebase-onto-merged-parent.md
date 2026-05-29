---
class: principle
date: 2026-05-29
skill: wk-pr-update
---

# Rebase --onto to skip a merged parent branch's commits

- **Rule:** When a branch was stacked on a parent that since merged into the
  base, replay only this branch's own commits with
  `git rebase --onto "$BASE_REF" <merged-parent-tip-sha>` — not plain
  `git rebase "$BASE_REF"`.
- **Why:** Plain rebase replays the parent's commits too, producing add/add
  conflicts on files the parent introduced — files this branch never touched.
- **Where:** Stage 3a "Rebase strategy" — "Merged-parent branches" note.
- **Detect:** unexpected add/add conflicts on untouched files right after a
  parent branch merged.
