---
class: principle
severity: medium
date: 2026-06-12
---

**Rule:** Treat Q&A, open-questions, decision-log, and decisions sections as first-class grep targets during removed/renamed field sweeps.

**Why:** These sections contain field paths but lack bullet/table structure, so prose sweeps miss them. A stale field path in a Q&A answer creates a circular stale reference that bypasses all existing enumeration checks.

**Where:** Section 2.8 (Cross-doc enumeration sync) — new bullet before "Named sweep targets."
