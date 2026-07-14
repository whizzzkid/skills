---
class: principle
---

**Rule:** When composing the PR body, detect a prod-facing behavior change (diff
touches output posted to an external service/API, user-visible behavior, or a
runtime gate) and proactively include a `## Rollout` note — release shape
(flag/canary/staged vs. plain), backward-compatibility, and rollback shape. Even
a one-line note satisfies the check.

**Why:** The review-time sweep verifies a rollout section exists, but it fires
after `gh pr create`, so a prod-facing diff can reach creation without one and a
description-check bot flags it — forcing a reactive body edit on the round trip.
Composing it up front avoids the cycle.

**Where:** Step 2 body composition (detail in `references/pr-body-extras.md`).
