---
skill: wk-pr-update
date: 2026-08-24
type: pattern
severity: medium
verified-against-source: n/a
---

Cherry-pick onto new base after upstream squash-merge avoids conflict resolution

**What happened:** When a stacked PR's base branch was squash-merged, rebasing the child onto the updated target produced conflicts from the squash delta. Cherry-picking the child's commits onto the new base avoided conflict resolution entirely.

**Root cause:** Rebase replays each commit against the squash — every commit that touched squashed lines conflicts. Cherry-pick onto the post-squash tip skips the delta because the base state already includes the squashed content.

**Suggested fix:** Document cherry-pick as the preferred technique when retargeting a stacked PR after the base was squash-merged — rebase through the squash delta is unnecessary conflict work.
