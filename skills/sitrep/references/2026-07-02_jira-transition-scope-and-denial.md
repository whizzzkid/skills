---
class: principle
skill: wk-sitrep
date: 2026-07-02
severity: medium
---

- **Rule:** Live Jira ticket-state transitions are a `start`-only action
  (Stage 2b). During `end`, never transition a merged-but-still-open ticket —
  render it as a flagged carry-forward item for the user to transition manually.
  Even in `start`, a transition may be denied by the harness write-permission
  policy; on denial, degrade to a pending carry-forward item rather than
  retrying or failing the run.
- **Why:** During an `end` compilation, tickets with PRs merged days earlier but
  still in "In Review" were auto-transitioned by extrapolating the `start`
  Stage 2b behavior into `end` — where it is not documented. The harness
  classifier denied the write twice as an unrequested external-system mutation
  (the ticket was not created this session and the intent came from a subagent's
  findings, not a direct same-turn user ask). The harness treats any
  external-system state mutation — transitions, not just deletions — as needing
  same-turn explicit user intent, even for a documented step of an
  already-invoked skill.
- **Where:** Stage 2b intro — scoped the transition stage to `start` only, added
  the `end` carry-forward rule and the graceful-degradation-on-denial rule.
