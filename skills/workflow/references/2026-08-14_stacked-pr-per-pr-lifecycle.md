---
class: principle
skill: wk-workflow
---

# Stacked PRs require per-PR lifecycle completion

**Rule** — Each PR in a stacked chain must independently complete Phases 5 → 6.5
(publish, adversarial review, CI green, review-comment resolution). Batch-pushing
all PRs as drafts without completing the lifecycle per PR is a violation.
Platform-pinned CI artifacts must be regenerated inside the documented CI
container, not on the local host.

**Why** — A 4-PR stack was left entirely as drafts after push; adversarial review
and `gh pr ready` were skipped, platform-specific artifacts were regenerated on
the wrong host causing CI failures, and bot review comments were ignored.

**Where** — Phase 5 (Stacked PRs — per-PR lifecycle) and Phase 3.6 (platform-pinned
CI artifacts).
