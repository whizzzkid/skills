---
class: principle
---

# PR created is not done; a phase PR ships only its phase

**Rule**

- Start the CI watch in the same turn as every PR create or push, and complete it; never report a phase or PR done
  before CI is green or a diagnosed failure is surfaced.
- Scope each phase PR of a multi-phase spec or plan to that phase's stated deliverable; scaffolding, jobs, schema
  fields, config keys, or columns only a later phase uses wait for that phase.

**Why**

- After opening a stacked draft PR, the agent summarized results instead of entering the CI fix loop; CI was red.
  The Phase 5 HARD RULE ("push succeeded is NOT work complete") and the Phase 6 "complete CI watches same turn" bullet
  were both installed before the report, so this is a re-violation.
- The same phase PR also shipped later-phase scaffolding the user had not asked for; no rule tied a phase PR's scope
  to that phase's deliverable (cross-repo scope and multi-deliverable granularity rules cover different axes).

**Escalation**

- Phase 6 CI-watch bullet: baseline → `**Important:**` (one rung), merged with the PR-create trigger.
- Phase 5 HARD RULE extended to name "PR created" and hand off to the Phase 6 watch in the same turn (no label change).
- Phase-scope rule is new (baseline) in Phase 2.

**Where**

`skills/workflow/SKILL.md` → Phase 2 (phase-scope bullet), Phase 5 HARD RULE, Phase 6 CI-watch bullet.
