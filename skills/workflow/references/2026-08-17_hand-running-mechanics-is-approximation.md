---
class: principle
---

# Hand-running a skill's mechanics IS the forbidden approximation

**Rule** — Skill invocation is mandatory: use the `Skill` tool, never a hand-run
equivalent of the skill's mechanics. A raw `git commit` in place of the commit
skill, or ad-hoc planning in place of the plan skill, is that approximation. A
session's first write-action is where it gets skipped.

**Why** — The rule existed as baseline prose and read as a policy about *choosing*
between a skill and something else. The failing session did not deliberate: it
performed the skill's underlying mechanics directly and never recognized that as
"approximation", because raw git and informal planning don't feel like substitutes
— they feel like just doing the work. Naming the concrete instances converts an
abstract prohibition into something recognizable at the moment it is violated.

**Where** — `skills/workflow/SKILL.md` → the act-without-asking rule list.

## Escalation record

- Three lessons from one source (workflow, plan, and commit skills each bypassed)
  are one re-violation of one rule, escalated **once**: rung 1 (baseline prose) →
  rung 2 (`**Important:**`). Three notches for three symptoms of a single failure
  would burn the ladder on one incident.
- Rule installed 2026-04-20, report 2026-08-11 → the text was live during the
  failing run, so the notch applies.
- No positive-steering evidence blocked it: the session's "What worked" bullets
  covered a targeted fix and honoring a branch-point correction, not skill routing.

## De-bloat in the same pass

- Reclaimed 156 B by shrinking the pre-rework base-reconcile rule to its pointer
  plus the one clause its linked reference does *not* state ("never assume default
  as the rebase target"). The enumeration of rework triggers and the recipe both
  live in that reference in full, so the inline copy was duplicated by
  construction. The unique clause was kept inline deliberately — do not "finish"
  this relocation by deleting it.
