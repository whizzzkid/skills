---
skill: wk-sharpen
date: 2026-07-25
type: gap
severity: high
verified-against-source: yes
---

A re-violation only indicts a rule that was actually installed — compare installed text to
worktree text before spending an escalation notch.

**What happened:** Two rules in one skill were both cited as re-violated, and the
escalation HARD RULE treats a fresh repeat as automatic grounds for one notch. Comparing
the installed `SKILL.md` against the worktree revealed the two cases were not alike: one
rule was present verbatim in the installed skill (genuinely in force, genuinely
re-violated → notch justified), while the other's strengthening existed only as an
uncommitted worktree fold and had never shipped (zero occurrences of its key phrase in the
installed file). Escalating the second would have hardened a rule that was never in force
for the run that "violated" it.

**Root cause:** The escalation rule reasons about the *repo's* text, but the agent that
failed was steered by the *installed* text. When a repo carries uncommitted folds — the
normal state when a commit gate is blocked — those two diverge, and every unlanded fold
looks like a failed fold. The skill has no step that distinguishes "rule failed" from
"rule never shipped," so a blocked commit gate silently manufactures false re-violation
evidence and burns ladder headroom on rules that were never tested.

**Suggested fix:** In the re-violation escalation HARD RULE, add a precondition beside the
existing positive-steering exception: before escalating, confirm the rule's current text is
present in the installed skill, not only in the worktree. Diverged → the fold is unshipped;
classify as `already-covered (unshipped)` and do not escalate. Note that escalation is a
volume knob — when the repeat traces to the rule's *shape* (the failing case not matching
how the rule is framed), the framing fix is the load-bearing change and the notch only
records the repeat.
