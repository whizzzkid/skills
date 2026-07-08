---
skill: wk-sitrep
date: 2026-07-02
type: gap
severity: medium
---

Auto-transitioning a merged-PR's linked Jira ticket to Done during the `end` sub-command was blocked by the harness's auto-mode write-permission classifier, and the behavior was misapplied — it's documented as a `start`-only stage.

**What happened:** During `end` compilation, two tickets were found with linked PRs merged days earlier but still sitting in "In Review." Attempting to transition them to Done (modeled on the `start` sub-command's auto-transition stage) was denied twice by the permission classifier as an unrequested external-system write, since the ticket wasn't created this session and the transition intent originated from a subagent's findings rather than a direct user ask this turn.

**Root cause:** The skill's auto-transition stage is scoped to `start` only, not `end` — applying it during `end` was an extrapolation beyond what the skill actually specifies. Separately, the harness treats any external-system state mutation (ticket transitions, not just deletions) as requiring same-turn explicit user intent, even when the mutation is a documented step of a skill the user did invoke.

**Suggested fix:** During `end`, do not attempt ticket transitions for merged-but-not-transitioned tickets — instead render them as a flagged carry-forward item (e.g., ASAP bucket) so the user transitions manually. Only attempt live ticket-state writes during the `start` sub-command's documented auto-transition stage, and even there, expect the write may be denied by a stricter harness policy — degrade gracefully by surfacing it as a pending item rather than retrying or failing the whole run.
