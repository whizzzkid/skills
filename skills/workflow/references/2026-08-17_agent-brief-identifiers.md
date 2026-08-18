---
class: principle
source: learnings/skills/workflow/2026-08-17_brief-agents-with-actual-tokens.md
date: 2026-08-17
severity: medium
---

## Agent-brief identifiers come from source, never recall

A coordinator briefing parallel agents supplied identifier names recalled from
convention rather than read from the declaring file. The real names differed. One
agent noticed and read the source itself; the rest would have written code against
names that do not exist.

**Failure mode:** the brief is the only shared vocabulary the agents have. A single
unverified identifier in it propagates into every agent that trusts it, and the
coordinator does not see the breakage because each agent fails independently.

**Guard:** grep the declaring source for the exact names and values before drafting
any prompt that names them; quote the declarations into the brief. Applies to every
class of shared identifier — style tokens, config keys, env var names, API response
fields, database columns — not just the class that surfaced it.

**Generalized from:** the report prescribed reading one specific stylesheet class.
The mechanism is recall-vs-source for any identifier crossing an agent boundary, so
the rule is written to that boundary instead.

**Landed in:** `SKILL.md` Phase 2 → "Edit-scope pre-flights" → "Agent-brief
identifiers" bullet.
