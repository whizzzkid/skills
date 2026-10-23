---
class: principle
---

# Ternaries: one level, one line, never inside a call argument

**Rule** — a ternary must be single-level, fit on one line, and stand alone (never embedded in a call argument).
Otherwise hoist the choice into a statement: a default value plus a plain `if` override (where the language rules
permit reassignment), `if/else`, or an early return. A two-way choice is not exempt.

**Why** — the structure rule banned only nested ternaries, so a non-nested ternary read as always acceptable; the
user rejected a line-spanning ternary and an argument-embedded one as hard to read. The multi-line ban already lived
here (installed before the report) and was re-violated, so this bullet escalated one rung (baseline →
`**Important:**`). The remedy names reassignment as conditional because `wk-workstyle-typescript` prefers `const`.

**Where** — owning rule: `skills/workstyle-structure/SKILL.md` → Rules → Structure (ternary bullet, rewritten from
"No nested ternaries"). Escalation: `skills/format/SKILL.md` → Dislikes → *No multi-line ternaries*. Filed under
`format/references/` because `workstyle-structure` has no `references/` directory.
