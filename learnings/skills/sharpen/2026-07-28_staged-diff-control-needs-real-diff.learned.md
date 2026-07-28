---
skill: wk-sharpen
date: 2026-07-28
type: gap
severity: high
verified-against-source: yes
---

A control for a staged-diff-triggered gate is dead unless the staged files actually differ
from `HEAD`, and the dead run is indistinguishable from a clean pass.

**What happened:** After writing a new pre-commit hook, the run built a repo-wide
false-positive control: stage every `SKILL.md` in the tree unchanged, run the hook, expect
zero violations. It printed a clean pass. The control was dead — `git add` of a file whose
content already matches the index produces no staged diff, so the hook's own trigger
(`git diff --cached --name-only` non-empty) saw nothing and the hook exited at its guard
clause without evaluating a single reference. The green was byte-identical to a real pass:
rc 0, no output. It was caught only because the control also printed the staged count,
which read `0` against an expected 63.

Rebuilt so the diff is real while the property under test stays untouched — append one
trailing blank line to each `SKILL.md` blob and stage that — the same control ran the hook
across 63 skills and returned a meaningful zero.

**Root cause:** Two compounding gaps, both confirmed by driving the hook.

- The installed rule *"a control target must be able to produce a hit under the scan's own
  invocation form"* exists and covers this exactly in principle, but it sits in the **Batch
  Mode preamble** and is written about source scans and traversal primitives. Nothing
  carries it to the Step 5 / Step 8 controls that verify a **gate** the fold just wrote, so
  it did not fire here. Its sibling rules (`control-target-must-admit-a-hit`,
  `control-must-reach-compare`, `collation-control-must-disagree`) share that scoping.
- Nothing names the specific mechanism. For a filesystem scan the blind spot is a
  traversal that skips a node class; for a staged-set gate it is that **staging is not the
  trigger — a staged *difference* is**. Constructing the control the obvious way (stage the
  inputs) is precisely what disarms it, so the natural construction is the broken one.

**Suggested fix:** Generalize the control-target rule out of the Batch Mode preamble so it
governs any control a run builds, including controls for a gate the fold itself is adding,
and give it the staged-set instance: a gate triggered by a staged diff cannot be exercised
by staging unmodified files — introduce a real, semantically-null difference (append a
trailing newline to each blob) so the trigger fires while the property under test is
unchanged. Require the control to assert the **trigger's own count** is non-zero
(`git diff --cached --name-only | wc -l`) before reading the gate's verdict; a gate's exit
code can never distinguish "evaluated and clean" from "never ran".

Sibling instance worth folding with it: the six single-case arms in the same run were live
only because each was built by mutating a blob, not by staging an unchanged file — so the
defect hit exactly the one arm whose construction differed. A control family is not
verified by its members agreeing.
