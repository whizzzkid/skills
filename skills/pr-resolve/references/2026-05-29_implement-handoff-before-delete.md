---
class: principle
skill: wk-pr-resolve
date: 2026-05-29
---

# Implement handoff docs before deleting them

- **Rule:** Before removing any handoff doc (`RUN_LOCALLY.md`, `NEXT_PHASE.md`,
  `HANDOFF.md`, or any filename signalling remaining work), read it fully and
  implement every item; delete only in the same commit as the last
  implementation change.
- **Why:** The adopt-and-resolve flow focuses on conflicts and review comments
  and had no step to action handoff docs — deleting one as "cleanup" silently
  drops the work it tracked.
- **Where:** Hard Rule 12.
