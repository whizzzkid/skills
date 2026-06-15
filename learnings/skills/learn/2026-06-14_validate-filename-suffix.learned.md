---
skill: wk-learn
date: 2026-06-14
type: gap
severity: low
---

Validate the learning filename suffix before staging a new learning file.

**What happened:** A new learning risked being written with a `.learned.md` suffix, which marks it already-distilled and makes wk-sharpen skip it.

**Root cause:** Step 3 did not require validating the filename suffix/shape before writing or staging.

**Suggested fix:** A new learning ends in `.md`, never `.learned.md`; confirm the path matches `<YYYY-MM-DD>_<slug>.md` before writing or `git add`. (Materialized from retrospect 2026-06-14_session-1.)
