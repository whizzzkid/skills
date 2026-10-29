---
skill: wk-sitrep
date: 2026-10-29
type: gap
severity: medium
verified-against-source: n/a
---

Auto-launched reviews were spent on already-settled pull requests, ran at the wrong depth, and were never surfaced.

**What happened:** The start flow launched medium-depth reviews on pull requests that merged or were already approved by the time the drafts landed, left the drafts unopened, and the page then listed dozens of stale unsubmitted drafts on merged or closed pull requests, so the pending count kept growing.

**Root cause:** Candidates were taken from the gather snapshot without re-checking live state before dispatch, the review depth defaulted to medium, and nothing opened a finished draft for the user or pruned drafts whose pull request had closed.

**Suggested fix:** Re-query state and review decision immediately before dispatch and skip merged, closed or approved pull requests; use the lightest review mode; have the orchestrator open each posted draft; list only drafts on still-open pull requests, and re-check state at publish time since pull requests merge while reviews run.
