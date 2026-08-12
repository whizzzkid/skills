---
class: principle
date: 2026-08-11
skill: wk-pr-update
---

# Proactive detection of independently-merged parent history

- **Rule:** Before Stage 2 strategy selection, compare files added on the branch
  since the fork against files added on base. Significant overlap signals a stacked
  branch whose parent commits merged into base via separate PRs. Route to
  `rebase --onto` (Stage 3b) to skip the duplicated prefix.
- **Why:** Without proactive detection, a plain merge or rebase replays the
  duplicated parent history, producing massive add/add conflicts on files
  introduced by both histories — ~30 conflicts in the triggering incident.
- **Where:** Stage 1 → "Independently-merged parent detection"; Stage 2 table →
  new routing row.
