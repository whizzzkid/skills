---
class: principle
---

**Rule:** After a push to a branch with an open draft PR, watch CI to completion
in the same turn; once green, run `gh pr ready` yourself. Never end a turn by
delegating the final action ("CI is running, mark ready once it passes") to the
user.

**Why:** Phase 5/6 already cover "mark ready after green," but the specific
re-violation was ending the turn handing `gh pr ready` to the user as a manual
step. Narration of a holding pattern is not the work; the turn's work is not done
until the action this turn can complete is executed.

**Where:** Phase 6 (CI Fix Loop) — escalated the "never end a turn announcing a
holding pattern" bullet to also ban delegating the final action.
