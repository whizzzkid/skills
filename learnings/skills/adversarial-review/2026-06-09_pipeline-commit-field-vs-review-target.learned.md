---
skill: wk-adversarial-review
date: 2026-06-09
type: gap
severity: high
---

When a Buildkite payload has both a `commit` field and an env var carrying a target SHA, verify which repo each refers to before accepting a change that swaps them.

**What happened:** A bot flagged `commit:"HEAD"` as risky because the build might check out a newer commit than the target SHA. The fix accepted was `commit:$sha`, using the review target's SHA as the pipeline commit. The adversarial subagent caught that the target SHA (from a different repo) does not exist in the pipeline repo, so the build would fail at clone.

**Root cause:** No mechanical sweep checks whether a `commit` field in a Buildkite/CI payload refers to the pipeline repo or the target repo. The two uses look identical in the diff but are semantically opposite.

**Suggested fix:** Add a check: when a diff changes a `commit` field in a CI trigger payload, verify whether the value is drawn from an env var representing a *foreign* repository's SHA (typically named `REVIEW_*`, `TARGET_*`, `SOURCE_*`). A foreign-repo SHA used as the pipeline commit field is always wrong and should be flagged as a blocker.
