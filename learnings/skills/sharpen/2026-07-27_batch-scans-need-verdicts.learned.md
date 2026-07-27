---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

The verdict protocol was folded scoped to Step 5's two hand-rolled scans, but batch mode's
source re-lists are scans of the same construction and carry no verdict discipline — the
defect re-occurred there in the very run that folded it.

**What happened:** Immediately after landing a fold whose whole point is "a printed banner
is not a verdict", the same run renamed a processed learning and re-listed Source 2 with a
one-liner that ran `find` and then unconditionally echoed `(empty = drained)`. The `find`
output was non-empty — the rename had failed, because `git mv` refuses a path that was
never tracked — yet the banner printed "drained" directly beneath the file it had just
listed. The contradiction was visible only because the raw `find` output happened to sit in
the same output block, which is the identical accident that caught the original incident.

**Root cause:** The fold generalized one notch short. It restated the protocol as a property
of "any hand-rolled scan", but anchored the enumeration to Step 5 — the staged path scan and
the overfit category scan. Batch mode runs its own scans (`find` over the learnings tree,
the memory listing gate, the marker diff) whose verdicts decide whether a source is called
drained, and Source 2's bullets specify *when* to re-list and *what* the terminal state is
without ever saying the verdict must branch on the scan's status. A "drained" verdict is
exactly the high-stakes zero the skill elsewhere insists on proving with a canary, so the
omission sits where it costs most.

**Contributing detail worth keeping:** the rename step is a known trap in its own right. A
learning file is deliberately left untracked until distillation, so `git mv` always fails on
it; the fallback is plain `mv`. A run that treats the rename as succeeded and then trusts an
unconditional banner will report a source drained while the learning is still sitting there
unprocessed — silently losing the item rather than deferring it.

**Suggested fix:** Extend the verdict protocol's stated scope from "Step 5's hand-rolled
scans" to every scan whose result the skill acts on, batch-mode source re-lists included,
and say so where the drained verdict is defined rather than only in the Step 5 reference.
Pair it with the existing canary rule: a source is drained only when the scan exited 0 *and*
returned nothing, never when a banner says so. Consider naming the untracked-learning rename
(`mv`, not `git mv`) at the point Source 2 prescribes the rename, since a failed rename is
the most likely way a stale "drained" verdict gets produced.
