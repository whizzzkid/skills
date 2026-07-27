---
class: principle
---

# Escalation evidence must be checked against the installed skill, not the worktree

**Rule** — Before spending an escalation notch on an `already-covered` repeat, confirm the
rule's current wording is present in the *installed* skill. Installed text diverges from
the worktree → the fold never shipped; classify `already-covered (unshipped)` and spend no
notch.

**Why** — The escalation rule reasons about the repo's text, but the agent that failed was
steered by the installed text. A repo carrying uncommitted folds — the normal state
whenever a commit gate is blocked — makes those two diverge, so every *unlanded* fold reads
as a *failed* fold. Escalating then hardens a rule that was never in force for the run that
"violated" it, and burns ladder headroom on rules that were never tested.

**Verified against source** — Not taken from the report. Diffed the installed `SKILL.md`
against the worktree copy this run: the two differed at six locations, including two rules
whose strengthening exists only as an uncommitted fold, plus a version-field divergence
(installed trailing the worktree). The divergence the learning describes was present and
load-bearing at the moment of distillation.

**Scope note distilled alongside it** — Escalation is a volume knob. When the repeat traces
to the rule's *shape* (the failing case not matching how the rule is framed), the framing
fix is the load-bearing change and the notch only records the repeat. Folded as a trailing
clause so a future run does not read the notch as the remedy.

**Classification** — `principle`. Generalizes to any skill whose guidance ships through an
install step separate from the repo edit.

**Escalation** — None. The re-violation HARD RULE carried a positive-steering exception but
no installed-vs-worktree precondition; this is a genuine gap, not a re-violation.

**Rejected reclaim targets (do not re-propose)** — Did not delete the reclaim-order bullet's
forward cross-reference to the de-bloat merge rule; a recorded decision places the full
statement at the earliest point and a deliberate short cross-reference later. Did not
delete the widened "unreachable ratio" antecedent at the binding-gate bullet; the inline
wording is *broader* than the linked reference's, so deleting it would narrow coverage.

**Where** — `SKILL.md` → Step 3, re-violation escalation HARD RULE, immediately after the
positive-steering exception.
