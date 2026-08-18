---
class: principle
source: learnings/skills/workflow/2026-08-17_skip-merge-skill.md
date: 2026-08-17
severity: medium
escalation: re-violation, one notch — prose rule to enumerated table row
---

## A lifecycle event missing from the autonomy table still belongs to its skill

With merges approved, the agent ran the merge CLI directly instead of invoking the
merge skill. The merges succeeded, so nothing failed loudly — but the wrapper's
post-action work (ticket transitions, follow-up collection, cleanup verification,
retro trigger) was silently skipped, and the user had to ask whether the skill had
run at all.

**Why it recurred:** the covering rule — hand-running a skill's mechanics is the
forbidden approximation — was installed roughly two and a half hours before this run
and still did not steer it. The autonomy table enumerated commit, PR, CI, review,
docs, and retro but not merge, and an enumeration with a gap reads as authoritative:
the absent event looks like it was deliberately left to the agent's discretion.

**Escalation applied:** one notch, prose rule to enumerated table row. The merge event
now has its own row, the forbidden-approximation list names the merge CLI explicitly,
and the table is declared illustrative rather than the closed set of skill-owned
events, so a future gap cannot be read as permission.

**Generalized past the report:** the report asked only for the one missing row. A
single row fixes this event and leaves the mechanism intact for the next event that is
missing, so the non-exhaustive clause carries the actual guard. The recurring shape is
reaching for a CLI the agent already knows over the skill that wraps it — the wrapper's
value is precisely the part that is invisible when skipped.

**Landed in:** `SKILL.md` Autonomy Rules → table row plus the mandatory-invocation
bullet.
