---
class: principle
---

# The escalation gate is temporal, not just locational

**Rule** — a re-violation notch is owed only against text that was installed *before the
report was written*. The pre-existing precondition compared **where** a rule lives (installed
vs worktree); it never asked **when** the rule arrived. Date the rule from history —
`git log -S '<needle>' -- <file>` — and compare that timestamp against the report's own. Rule
newer than the report → `already-covered (unshipped)`, no notch, regardless of installed and
worktree agreeing.

**Why** — the locational check catches only the blocked-commit-gate case, where a fold never
shipped at all. It is blind to the far more common batch-mode case: a peer run (or an earlier
pass of the same run) folds a lesson, commits it, and a report predating that commit is
processed afterwards. Both copies then agree, the precondition passes, and the ladder burns
headroom hardening a rule that was never in force when the run it "failed to steer" went
wrong. Backlog is processed **severity-ordered, not chronologically**, so report-older-than-
rule is the normal case rather than an edge case — this repo's own history shows rules landing
within the hour after the retrospects they were being scored against.

**Verified configuration** — reproduced on a git repo with linear history on one branch;
`git log -S` dated two sampled rules to their introducing commits. Not exercised against a
rule whose text was reflowed after introduction (the `-S` needle would then date the reflow,
not the rule) — prefer the shortest stable fragment of the rule as the needle.

**Rejected suggestion (do not re-propose)** — the report also offered
`git log -1 -L <lines>:<file>` as a dating primitive. Rejected: a line-range anchor conflicts
with the target's installed rule that every exact-match anchor be sliced from the file's bytes,
and with the Core Rule against line numbers as durable references — line numbers go stale the
moment anything above them shifts. Only the `-S` form survived translation into the sanctioned
tooling, so only it was folded.

**Classification** — `principle`, `partial`. The existing bullet covered the unshipped-fold
half correctly; only the temporal half was missing.

**Escalation** — none. Positive-steering evidence blocks it: the reporting run classified both
items `already-covered (unshipped)` correctly, having caught the temporal problem by hand. The
existing rule did not misfire; it was silent on a case it never named.

**Reclaim decision (scored under a cut-site-pointer shape)** — the batch-mode drained-verdict
bullet's canary *construction* clause (plant in-place, re-run the identical form, corroborate
with a blind-spot-free primitive) was cut at full value, its pointer to
[`batch-mode-sources.md`](batch-mode-sources.md) left at the cut site, where that reference
states the procedure in full. Retained inline: the requirement itself and the pass/fail verdict
("Drained = rc 0 **and** empty output, never a banner"), which the reference does not carry.
This follows the split already recorded in
[`2026-07-25_canary-pointer-at-first-gate.md`](2026-07-25_canary-pointer-at-first-gate.md) —
requirement and verdict inline, construction mechanics in the reference. The four standing
canary rejection notes were checked first and none covers this bullet; all four protect the
Step 3 prohibited-subject-gate canary and its `staged-path-scan.md` pointer.

**Arithmetic for the fold** — body 24478 B, ceiling 24576 B, headroom **98 B** (trigger fired).
Step 5 audit run *before* the budget locked → measured allowance **0 B** inside the ceiling-bound
file (the reference file and the README `Version:` bump and narrative fix carry no ceiling).
Addition **+143 B** (escalation bullet, 446 → 589 B) against reclaim **−150 B** (drained-verdict
bullet, 407 → 257 B). Net **−7 B** → staged body **24471 B**, every ceiling clear. The ≥1.2×
planning ratio (0.81) was unreachable without cutting load-bearing content; per the binding-gate
rule the arithmetic is reported and the hunt was not widened — the addition was tightened
instead, twice, each revision re-measured before it was applied.

**Where** — `SKILL.md` → Step 3 → *HARD RULE: re-violation escalation*; reclaim taken from
Batch Mode → drained-verdict control bullet. README narrative on re-violation scoring updated
in the same pass.
