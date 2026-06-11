---
skill: wk-workflow
date: 2026-06-10
type: gap
severity: low
---

Sync spec New Files / Modified Files tables in the same commit batch as a base class extraction, not as a deferred docs fix.

**What happened:** A base class was extracted mid-session from two existing classes. The new file was committed correctly, but the spec's "New Files" table was not updated until the adversarial review flagged the discrepancy in a later pass. This created an unnecessary fix commit and a brief window where the spec was stale.

**Root cause:** The workflow's docs-audit step runs after the implementation batch, but cross-doc enumeration sync (sweep 2.8) fires only at adversarial-review time. The implementation phase has no explicit "after extracting a shared class, add it to the spec table" reminder.

**Suggested fix:** During Phase 3 (Implement) refactor commits that add new files, also check the spec's New Files / Modified Files tables and update them in the same commit. Treat spec table entries as part of the file's creation commit, not deferred cleanup.
