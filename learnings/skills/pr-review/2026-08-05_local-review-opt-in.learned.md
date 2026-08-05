---
skill: wk-pr-review
date: 2026-08-05
type: correction
severity: medium
verified-against-source: n/a
---

Optional local reviewers require explicit per-request authorization.

**What happened:** The user preemptively reiterated that a model-backed local reviewer must not run while the review workflow consumed an existing CI-triggered review.

**Root cause:** The review workflow can conflate validating existing bot output with triggering a fresh local review and has no explicit opt-in gate.

**Suggested fix:** Add a hard rule that optional local or external reviewers run only when the user explicitly requests them in the current task; otherwise consume existing CI-triggered results without launching a new review.
