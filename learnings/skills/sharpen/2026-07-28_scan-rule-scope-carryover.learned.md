---
skill: wk-sharpen
date: 2026-07-28
type: correction
severity: medium
verified-against-source: yes
---

The one-quoted-path-per-grep rule was re-violated because it is written as a property of
Step 5's staged-path scan rather than of any grep whose zero is load-bearing.

**What happened:** During the Step 5 overfit scan the run collected five paths into a
space-separated shell variable and passed it as a single quoted argument to `grep`. `grep`
resolved it as one nonexistent filename, wrote `No such file or directory` to stderr, and
exited non-zero. The trailing `|| echo "  none"` turned that failure into a clean verdict,
so two of the four scan categories reported `none` while having scanned nothing. Only
reading grep's stderr in the output caught it; the scan was then rebuilt as one quoted path
per invocation with the verdict taken from each scan's own rc, distinguishing rc 0 (hit),
rc 1 (clean) and rc ≥2 (error).

**Root cause:** The rule is installed and states the fix exactly — *"one quoted path per
grep, verdict on that scan's own rc — a banner is not a verdict"* — with the mechanism in
its own linked reference. But it is a sub-bullet of the Step 5 instruction about scanning
**staged path strings**, so it reads as a property of that particular scan. The overfit
category scan is a different file set at a different moment, and the rule did not carry
across. The same misreading is available for every other grep a run performs whose
emptiness is load-bearing (the Step 3 prohibited-subject gate, the Step 2 subject grep,
the drift greps) — each currently restates or omits the discipline separately.

Confirmed against the source: the rule's text and its reference both describe the failure
in terms of the staged set, and the Step 2 zero-match rule is stated separately again for
its own case, which is the duplication that scoping produces.

**Suggested fix:** State the discipline once as a property of the grep, not of the scan
that happens to use it, and cross-reference it from the places that currently restate it:
any grep whose zero is load-bearing takes one quoted path per invocation, branches on rc
0 / 1 / ≥2 as hit / clean / error, and never lets `||` supply a verdict — an error and a
clean result are different outcomes and `||` merges them. This also subsumes the existing
Step 2 "treat a zero-match grep whose emptiness is load-bearing as unverified" bullet
rather than sitting beside it.

**Escalation:** No positive-steering evidence. The rule did not fire; the defect surfaced
from reading grep's stderr, which is self-correction, not the rule working. A distilling
pass should weigh a notch against the rule's **framing** — the repeat traces to its
scoping, so relocating and generalizing it is the load-bearing change and the notch only
records it.
