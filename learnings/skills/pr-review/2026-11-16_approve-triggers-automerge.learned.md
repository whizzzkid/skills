---
skill: wk-pr-review
date: 2026-11-16
type: gap
severity: high
verified-against-source: n/a
---

Approving a PR that has auto-merge enabled merges it immediately, so open suggestions/questions never get addressed.

**What happened:** In `light approve` mode the approve gate passed: zero `concern:` comments, CI green, author not the
reviewer. The review was submitted as APPROVE with three open `suggestion:` comments. The author had enabled auto-merge
(squash) days earlier, and approval was the last missing requirement, so the PR merged about two minutes later. The
author never saw the suggestions before merge. The squash commit also used a body captured when auto-merge was enabled,
which the description had since contradicted.

**Root cause:** The Approve Flag gate treats `suggestion:`/`question:` as non-blocking and never checks
`autoMergeRequest`. Approval is assumed to be advisory, but with auto-merge on it is the merge trigger.

**Suggested fix:** Add to the Approve Flag gate in Phase 5, run after the live head/checks re-query:
- Read `gh pr view <n> --json autoMergeRequest`.
- If it is non-null and the review has any `suggestion:` or `question:` comment (or a `Re:` answer the author should act
  on): run `gh pr merge <n> --disable-auto` as its own Bash call *before* submitting APPROVE. Then add one sentence to
  the review body, e.g. "Auto-merge disabled so you can address the comments first; re-enable when ready." This is an
  allowed body-sentence exception alongside the existing three.
- If disabling fails (permission denied, API error), do not approve. Hold the review as pending and report in the
  terminal: "approve requested; held as pending: auto-merge on and could not be disabled".
- Clean review (no actionable comments) with auto-merge on → approve normally; merging is the intended outcome.
- Report the auto-merge state and action in the terminal summary in all cases.
