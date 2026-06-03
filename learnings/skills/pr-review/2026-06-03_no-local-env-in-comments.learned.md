---
skill: wk-pr-review
date: 2026-06-03
type: correction
severity: high
---

Never disclose local environment failures in GitHub review comments — stop and ask the user to fix the env before continuing.

**What happened:** The review body disclosed that integration tests couldn't
run locally (container daemon not running) and stated "CI is the arbiter."
This leaked a local setup problem into a published review comment visible to
the PR author and other reviewers.

**Root cause:** The skill has no explicit gate that blocks progress when the
local environment is broken. Instead it proceeded and disclosed the gap in the
review body as a caveat, treating it as an acceptable workaround.

**Suggested fix:** In Phase 4, when any environment prerequisite fails
(container daemon unavailable, bundle not installed, DB unreachable, runtime
missing), **stop immediately** and surface the failure to the user in the
terminal with a clear ask:

> "Local environment issue: {failure}. Please fix and re-run the review.
> Proceeding without a working env risks an incomplete or misleading review."

Do NOT continue to Phase 5/6 with degraded coverage and do NOT mention the
local setup failure in any GitHub-posted comment, review body, or inline note.
The review author should never see evidence of the reviewer's local machine
state.
