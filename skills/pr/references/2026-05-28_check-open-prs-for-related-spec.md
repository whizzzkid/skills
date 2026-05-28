---
class: principle
date: 2026-05-28
source:
  - learnings/skills/wk-pr/2026-05-28_check-existing-specs-before-new-doc.md
severity: medium
---

- **Rule** — before adding a new `docs/specs/` doc, search open PRs for a spec in the same domain; prefer stacking onto the existing spec over a parallel doc.
- **Why** — a parallel spec in another in-flight PR forces a later merge/consolidation request and rebase; checking the current branch's docs alone misses in-flight specs.
- **Where** — wk-pr Step 1, "Check open PRs for a related spec before adding a new one" — reuses the open-PR list already fetched for base detection.
