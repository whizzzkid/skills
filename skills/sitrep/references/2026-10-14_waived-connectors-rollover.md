---
class: principle
---

# User waivers for required connectors and stale-page rollover

**Rule**

- The required evidence set is the roster's company-data domains minus user waivers: `waived_connectors:` in
  `.sitrep.yml` (comma-separated; persisted only when the user waives "for all runs") plus any the user waived for
  the current run. Nested rollover `end` uses the same subtraction.
- A user-declared "treat the stale page as closed" skips rollover: no nested `end`, no snapshot, no
  `end_completed_at:`; open spans carry forward.
- Echo every waiver in the page's Meta section. Never infer a waiver from a failure.

**Why**

- A permanent access gap (a connector the user has no permission for) plus a stale prior page deadlocked every
  `start`: rollover needed the missing connector, and there was no way to mark the page closed without running `end`.

**Guard check**

- This does not relax the missing-connector abort: the abort still fires for every unwaived domain, and a waiver is
  an explicit user instruction (the abort already ends in "await instruction"), now made persistent and visible on
  the page rather than silent.

**Where**

`skills/sitrep/SKILL.md` → Core hard rules (connector abort) and Stage 0.5; `references/bootstrap.md` config parse;
`references/missed-end-rollover.md` Detect closure.
