---
class: principle
source: learnings/skills/pr-review/2026-10-20_snapshot-read-probe.learned.md
date: 2026-10-20
skill: wk-pr-review
---

**Rule** — Prove a check-then-act finding (non-locking pre-check inside an outer transaction reusing a stale
consistent-read snapshot) with a two-connection probe: reader opens a transaction and reads, a second connection
commits the conflicting change, then the reader calls the method. Compare head against a mutant with the pre-check
removed, then restore the file.

**Why** — The finding was reasoning-only until the probe turned it into evidence (error on head vs. success on the
mutant). It is the stale-snapshot variant of the real-connection rule from the same day, so it extends that bullet
rather than adding a new one.

**Where** — `SKILL.md` → Phase 3, concurrency sub-bullet under "logic-bearing findings need empirical proof".
