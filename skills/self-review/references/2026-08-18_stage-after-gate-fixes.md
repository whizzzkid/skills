---
class: principle
---

**Rule**

Stage a pending self-review only after every commit-producing action in the
current round has landed — including the adversarial-review gate fix loop. Verify
`position` matches `original_position` on each comment after posting; mismatch
means delete and re-stage.

**Why**

The adversarial-review gate routinely produces fix commits that rewrite files
the self-review anchors to, making anchor drift certain rather than incidental.
Treating drift as a recovery path rather than an ordering constraint wastes a
delete-and-rebuild cycle on every non-trivial PR.

**Where**

`SKILL.md` → Step 4 → first two bullets.
Escalated to `**Important:**` (re-violation: the generic "finish commit-producing
actions" rule was installed 2026-07-30 but did not prevent the incident because
the adversarial-review gate was not named explicitly).
