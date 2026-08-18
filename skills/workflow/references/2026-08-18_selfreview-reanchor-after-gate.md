---
class: principle
---

**Rule**

After the adversarial-review gate clears with fix commits that landed since the
self-review was staged, re-stage the self-review via `wk-self-review` before
proceeding to Phase 6.

**Why**

Phase ordering places self-review (Phase 5 via `wk-pr`) before the review gate
(Phase 5.5). When the gate's fix loop rewrites files the self-review comments
anchor to, the pending review's anchors are stale by construction. Without an
explicit re-anchor step, the stale review is silently handed to the user.

**Where**

`SKILL.md` → Phase 5.5 → **Clear** bullet.
