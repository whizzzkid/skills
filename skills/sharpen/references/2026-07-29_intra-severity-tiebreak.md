---
class: principle
---

**Rule** — A queue-ordering instruction must specify its tie-break, not only its sort key.
Source 2 is `severity-ordered, oldest mtime first within a band`. Oldest-first is the
load-bearing half: it is the only key every concurrent cycle can read without coordination,
and it bounds how long any one item can be skipped.

**Why** — `severity` is a three-value impact enum whose middle band is the catch-all
(`wk-learn` maps cosmetic / scope drift to `medium`), so the modal queue state is one wide
band — precisely the case a severity sort does not resolve. Verified against a live queue:
15 of 19 unprocessed items were `medium`, 4 `low`, none `high`; the sort determined the band
and nothing inside it. Each cycle then invents its own tie-break (newest, smallest, the skill
it already read), and two invented keys are as likely to collide on one file as to spread
across the queue. The collision is invisible until a rename lands, because the surrounding
claim rules detect a peer only via mtime and vanished-item checks, which presume the runs are
already reaching for different items. An undefined tie-break also makes drain order
unreproducible, so a hard item can be walked past indefinitely.

Oldest-first composes with the existing arrival rule rather than fighting it: an item whose
mtime postdates the run's start is unowned, and oldest-first never reaches such an item while
anything older remains. `mv` preserving mtime is harmless here — a processed item leaves the
queue by name, so the ordering key stays stable across the rename.

**Where** — `SKILL.md` → Batch Mode → Source 2, the scan bullet.
`references/loop-mode.md` spawn prompt carries the same key ("highest-severity,
oldest-mtime"), which previously said only "oldest" and so contradicted the severity sort.

**Reclaimed for this fold** — two Loop Mode bullets fully duplicated by
`references/loop-mode.md` (step 2's wait-for-completion, Termination's drained-queue stop);
the `references/loop-mode.md` pointer already sat at the cut site, and the exclusivity rule
and the completion-timed-delay rule stayed inline.
