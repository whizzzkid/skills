---
class: principle
date: 2026-07-27
severity: high
---

# Scope every local verification run to the changed examples

**Rule** — Step 5. Name the changed method's spec file and filter to it
(`<runner> <spec-file> -e '<changed method>'`). Never run a suite or a whole spec
directory. Mutation cycles inherit the same scoping.

**Why** — CI owns full-suite regressions; a green local suite run adds nothing and a red
one is usually environmental. The cost is multiplicative, not additive: the incident ran
a 200-example directory for the empirical pass *and* again for each of 20 mutations,
~19 minutes on a two-file diff adding one method. A killing test is by construction among
the changed examples, so the extra examples cannot change any verdict.

## Escalated, not merely re-stated

The prior rule ("Don't re-run the existing suite for general validation") was **installed**
and still failed, so this is a re-violation, escalated exactly one rung: baseline prose →
`**Important:**`. No same-session positive-steering evidence blocks the escalation — the
retrospect's "What worked" bullets cite mutation testing and mid-review head detection,
never scoping.

The escalation is not the substance. The repeat traced to the rule's **shape**: it was
framed as a prohibition on "the existing suite" while the failing runs were a *directory*
and a per-mutation re-run, neither of which the agent read as "the suite". The rule now
states the positive obligation (scope to the changed examples) and names the directory
case, and the mutation bullet carries the scoping explicitly — that bullet had no scoping
instruction at all, which is where 20 of the 21 wasted runs came from. The dropped
sentence "Running one targeted test to reproduce a specific suspected defect is fine" is
not lost coverage: the replacement mandates the targeted run rather than merely
permitting it.

**Where** — `SKILL.md` → Step 5 Playground Validation, first two bullets.
