---
skill: wk-pr-resolve
date: 2026-06-11
type: gap
severity: medium
---

Outdated threads should be resolved, not just skipped and noted.

**What happened:** When a thread is `isOutdated: true` and the underlying concern no longer exists in the current code, the skill noted it as "auto-skipped" in the summary but did not call `resolveReviewThread`. The thread remained open, contributing to the PR's unresolved thread count and appearing as outstanding feedback.

**Root cause:** The skill instruction said "skip truly outdated comments where the code has been rewritten and concern no longer applies — note these as auto-skipped in the summary." It described what to do for display but omitted the GitHub resolution step.

**Suggested fix:** After confirming an outdated thread's concern is no longer present in the code, call `resolveReviewThread` on it (same GraphQL mutation used for actively-worked threads). Update the skill's "Filter active comments" section: "Skip truly outdated comments … note these as auto-skipped in the summary **and resolve the thread via `resolveReviewThread`**." The resolution removes it from the PR's open-thread count so branch protection and reviewers see a clean slate.
