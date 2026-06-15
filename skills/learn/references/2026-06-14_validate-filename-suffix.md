---
class: principle
date: 2026-06-14
---

# Validate the learning filename suffix before staging

**Rule:** A new learning file ends in `.md`, never `.learned.md`. Before writing
or `git add`, confirm the path matches `<YYYY-MM-DD>_<slug>.md` (ISO date,
kebab-case slug, single `.md`).

**Why:** The `.learned.md` suffix marks an already-distilled file, so a new
learning mistakenly named `.learned.md` is silently skipped by `wk-sharpen` and
never processed.

**Where:** Step 3 Write the learning file, after the slug guidance.
