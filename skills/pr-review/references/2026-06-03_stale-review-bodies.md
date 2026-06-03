---
class: principle
---

- **Rule:** Cross-check each top-level review body's described files/approach against the current diff's changed-file set; mark `stale (superseded)` when it names files or an approach the PR no longer carries.
- **Why:** Comment-position staleness checks never flag a review with zero inline comments — a body summarizing an obsolete approach (branch rewritten after the body was generated) slips through as "active" and poisons the verdict.
- **Where:** Phase 2, new "Identify stale review bodies" subsection.
