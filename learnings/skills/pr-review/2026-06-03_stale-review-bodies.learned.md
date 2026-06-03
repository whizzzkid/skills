---
skill: wk-pr-review
date: 2026-06-03
type: gap
severity: medium
---

Top-level bot review *bodies* can be stale when the PR's approach was rewritten on the same branch — Phase 2 staleness detection only looks at inline comments.

**What happened:** A PR had two `{bot}` review bodies describing an
env-var-pinning approach and listing files (e.g. a settings file) that were no
longer in the diff — the branch had been force-rewritten to a different
approach. Phase 2's staleness logic keys on inline comments (`position == null`,
file modified after comment), so a review with **zero inline comments** but a
body describing a superseded design slips through as "active" and risks the
reviewer treating its claims as current.

**Root cause:** Staleness detection is comment-position-centric. A review body
that summarizes an obsolete approach has no position to invalidate, so nothing
flags it. Bot summaries are generated per-commit and never retracted when the
author pivots.

**Suggested fix:** In Phase 2, cross-check each review body's described
files/approach against the **current** diff's changed-file set. When a bot
review body references files absent from the current diff (or names an approach
the PR no longer takes), mark it `stale (superseded)` and note in the summary
that its claims describe a prior revision — do not carry its framing into the
verdict.
