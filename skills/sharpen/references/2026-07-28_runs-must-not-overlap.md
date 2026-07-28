---
class: principle
---

**Incident** — Four sharpen runs were in flight simultaneously; the user stopped
all four. Runs are meant to be strictly sequential.

**Principle** — A skill that defines what one run does must also define whether a
second may start. Nothing gated spawning on the previous run's completion, so an
interval-driven trigger stacked a new run on an unfinished one instead of skipping
the tick.

**Landed as** — Loop Mode in `SKILL.md` (exactly one agent in flight, delay timed
from completion, never a fixed cadence) plus the spawn/schedule/stop procedure in
`references/loop-mode.md`.

**Rejected** — A standalone dispatcher skill. It duplicated batch mode's queue
walk to add three rules; the rules belong in the skill that owns the fold. A
scaffolded dispatcher was reverted for this reason.

**Concrete hazards the rules cite** — two cycles claim one learning (the
`.learned.md` marker is a rename and `mv` preserves mtime, so neither mtime nor
commit recency reveals a peer); one cycle's byte-budget measurement is voided by
the other's edits landing mid-flight.
