---
class: principle
---

**Rule:** Treat agent-infrastructure artifacts — `.agents/`, `skills-lock.json`,
`.review-playground/` — as always disposable, even when not gitignored.

**Why:** The disposable-paths classifier previously recognized only gitignored
paths and common OS/editor artifacts. Skills-tooling-generated infra files fall
outside that set yet carry no unique session context and are regenerated on next
run, so they forced needless manual judgment during the pre-delete scan.

**Where:** Step 4 (Disposable paths — skip retro and clean without prompting).
