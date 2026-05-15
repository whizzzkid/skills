---
skill: wk-adversarial-review
date: 2026-05-15
type: pattern
severity: low
---

Bot re-reviews can echo stale findings from a prior cycle that are already addressed.

**What happened:** A bot reviewer flagged two helper functions as lacking direct unit tests. One (`repoProject`) had been covered in the *prior* review cycle's commit; the other (`githubCheckURL`) was a genuine gap. The bot's finding lumped both together.

**Root cause:** Bots run against the current diff but may generate findings based on file-level analysis that doesn't track commit-by-commit history. A function that gained a test in an earlier commit of the same PR can still appear in a "lacks tests" finding in a later cycle.

**Suggested fix:** When a bot finding covers multiple symbols/functions, cross-reference each against the PR's own commit log before classifying as a new gap vs. stale echo. The mechanical sweep should grep `*_test.*` for each named symbol and check if a matching test landed in `$BASE..HEAD` before escalating.
