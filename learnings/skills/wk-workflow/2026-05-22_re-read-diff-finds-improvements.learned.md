---
skill: wk-workflow
date: 2026-05-22
type: pattern
severity: low
---

Prompted self-review of a diff surfaced multiple architectural improvements the agent had missed.

**What happened:** User asked agent to "re-read the diff you just made and reconsider." Agent identified: puts in library code, duplicate ENV read, missing dispatch table for skip side-effects, un-normalized pr_number in annotation. All were real improvements.

**Root cause:** Agent had been adding features incrementally without stepping back to assess the whole. The re-read prompt forced coherent design review.

**Suggested fix:** After completing a multi-commit feature run (especially one with multiple back-to-back user requests), proactively re-read the full diff against main before offering to mark PR ready. A "coherence check" is cheaper than a user-prompted re-read.
