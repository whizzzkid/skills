---
skill: wk-adversarial-review
date: 2026-06-23
type: gap
severity: medium
---

Sibling functions introduced by a refactor can carry the same defect on a different line.

**What happened:** A bot review flagged a timeout error message using the actual elapsed time (`sub.Elapsed`) instead of the configured constant. The fix was applied to the flagged location. Adversarial review then caught an identical defect in a sibling function extracted in the same refactor PR — same logic, different line, same incorrect variable.

**Root cause:** The sweep checked only the flagged file location, not all similar patterns across the whole file. Refactor PRs that extract shared helpers often duplicate the original code before cleaning it up, propagating any defect into the new helper.

**Suggested fix:** Add a sweep step: when fixing an error-message or value-reporting defect, grep the entire changed file for all sites with the same shape (e.g., `grep "timed out after %v" <file>`) before committing. Treat every match as a candidate for the same fix unless a structural reason exists for divergence.
