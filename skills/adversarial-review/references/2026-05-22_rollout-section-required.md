---
name: rollout-section-required
description: Production-facing diffs require a rollout / rollback / monitoring section in the PR body.
class: principle
---

- **Rule:** When the diff touches production-facing surfaces
  (observability backend, deployment pipeline, schema migration,
  public API version, monitoring, paging), require a rollout /
  rollback / monitoring section in the PR body. Trigger via a
  path-pattern grep; check the body for the section.
- **Why:** A PR body listing only what changed in code, with no
  rollback plan or post-merge health signal, lets an outage during
  rollout go unnoticed. Reviewer bots routinely flag this.
- **Where:** Sweep 2.10 (PR metadata sync), "Rollout / operations
  section" bullet.
