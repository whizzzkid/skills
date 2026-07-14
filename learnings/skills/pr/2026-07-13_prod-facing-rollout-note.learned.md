---
skill: wk-pr
date: 2026-07-13
type: gap
severity: low
---

Prod-facing behavior change shipped a PR body without a rollout/rollback note, and an automated description-check reviewer flagged it after creation.

**What happened:** The change altered a review body posted to an external service (prod-facing) but the initial PR body had no `## Rollout` section. An automated description-check bot surfaced it as an informational finding, forcing a reactive body edit after `gh pr create`.

**Root cause:** Sweep 2.10 lists "rollout/ops section for prod-facing diffs" as a body element to verify, but it fires at review time, not at body-composition time — so a prod-facing diff can reach `gh pr create` without the section and get flagged by a description-check bot on the round trip.

**Suggested fix:** When composing the PR body (Step 2), detect a prod-facing behavior change (touches output posted to an external service/API, user-visible behavior, or a runtime gate) and proactively include a `## Rollout` note — flag/canary/staged vs. plain release, backward-compatibility, and rollback shape — even a one-line "additive + backward-compatible, ships with normal release, revert to roll back" satisfies the check and avoids a reactive edit.
