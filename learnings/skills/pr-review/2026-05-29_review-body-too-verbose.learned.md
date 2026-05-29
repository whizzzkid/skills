---
skill: wk-pr-review
date: 2026-05-29
type: correction
severity: medium
---

Review body narrated diff details the reader can see themselves — verdict and one key insight is enough.

**What happened:** The review body restated test counts, internal field names, and regex identifiers already visible in the diff. The author does not need the reviewer to read the diff back to them.

**Root cause:** Phase 6 "Compose the review body" guidance emphasizes what to include but doesn't explicitly prohibit narrating implementation details that are self-evident from the diff.

**Suggested fix:** Add a hard rule to Phase 6: the review body must not repeat information already visible in the diff (test counts, field names, variable names, list contents). Limit to: overall verdict, one non-obvious insight (e.g. a security or architectural implication the diff doesn't make obvious), and the footer.
