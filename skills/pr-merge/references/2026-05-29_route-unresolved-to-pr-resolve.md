---
class: principle
skill: wk-pr-merge
date: 2026-05-29
---

# Route unresolved comments to wk-pr-resolve before merge

- **Rule:** When the pre-merge gate finds any unresolved review thread,
  invoke `wk-pr-resolve` before any other merge action — never merge,
  never block-and-stop.
- **Why:** Halting strands reviewer feedback; merging buries it in a
  closed PR. Routing addresses it in-flow, then the merge resumes.
- **Where:** Step 4 (Verify all review threads are resolved) — HARD RULE
  at the top of the section, with a re-check after the resolve returns.
