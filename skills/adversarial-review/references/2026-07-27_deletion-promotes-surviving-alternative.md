---
class: principle
date: 2026-07-27
severity: medium
---

# Deleting one documented alternative makes every survivor load-bearing

**Rule** — Sweep 2.4. When a diff removes one member of a documented set of alternatives
(install paths, test modes, deploy targets, config options), treat every surviving member
as newly load-bearing: execute each documented command verbatim, and fix a failure in
*this* diff rather than deferring it as pre-existing.

**Why** — 2.4 checked doc *claims* against implementation, and the relocation-aware stance
correctly downgrades pre-existing issues a diff merely carries along. Neither covers a
deletion that changes a survivor's **criticality** without changing its text. The survivor
is unmodified and outside the changed lines, so no sweep looked at it — yet the diff is
what made the section 100% wrong instead of 50% wrong. In the incident the surviving
command had been broken since it was written (it passed a non-integer to a flag the tool
declares as an integer, aborting at argument-parse), and running the documented sequence
end to end surfaced it in one command.

## The carve-out is the load-bearing half

Adding the rule to 2.4 alone would have left the subagent's "Relocation-aware" stance
still instructing a downgrade on exactly this finding — two rules in the same file
disagreeing, with nothing to arbitrate. Both now carry the exception, and the older
`2026-06-01_relocated-code-severity-downgrade.md` was amended in place rather than left
as a blanket rule, since a stale unconditional downgrade gets either wrongly obeyed or
wrongly ignored.

Distinct from sweep 2.87 (a documented *path pattern* is executable): that rule fires on
patterns the diff touches. This one fires on text the diff does not touch at all.

**Where** — `SKILL.md` → Step 2 sweep 2.4 (Check + Fix columns); Step 3 subagent stance
"Relocation-aware".
