---
skill: wk-sharpen
date: 2026-07-28
type: gap
severity: medium
verified-against-source: yes
---

An installed rule can still have been absent when the run failed — date the rule against
the report, not against the worktree.

**What happened:** Three retrospects were checked for re-violations. Two bullets matched
installed rules exactly, and the installed text was identical to the worktree, so the
existing unshipped-fold precondition cleared them for an escalation notch. Dating the
rules told a different story: both had landed roughly half an hour *after* the
retrospects that recorded the failures were written. Neither rule was in force when the
runs it supposedly failed to steer went wrong. Both were classified
`already-covered (unshipped)` and no notch was spent.

**Root cause:** The installed-vs-worktree comparison tests *where* a rule exists, not
*when* it arrived. It catches the blocked-commit-gate case, where a fold never shipped at
all, but is blind to the far more common batch-mode case: a peer run (or an earlier pass
of this same run) folds a lesson, commits it, and a retrospect predating that commit is
processed afterwards. Both copies then agree, the precondition passes, and the ladder
burns headroom hardening a rule that was never tested. Backlog is processed
severity-ordered rather than chronologically, so a report is routinely older than the
rules it is compared against.

**Suggested fix:** In the re-violation escalation HARD RULE, make the installed check
temporal as well as locational: the rule's text must have been installed *before the
report was written*, not merely present now. Date the rule from history rather than
inferring it — `git log -1 -L <lines>:<file>` or `git log -S '<phrase>' -- <file>` — and
compare that timestamp against the report's own. Rule newer than the report →
`already-covered (unshipped)`, no notch, regardless of installed/worktree agreement. Note
the ordering hazard explicitly: severity-ordered batch processing makes report-older-than-
rule the normal case, not an edge case.
