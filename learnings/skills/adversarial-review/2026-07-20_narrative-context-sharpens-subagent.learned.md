---
skill: wk-adversarial-review
date: 2026-07-20
type: pattern
severity: low
---

Piping the fresh subagent a narrated summary of *why* each hunk changed (not
just the raw diff) let it verify the specific risk points precisely instead of
re-deriving intent from the patch alone.

**What happened:** Reviewed a merge-conflict resolution plus a one-line bugfix.
Rather than handing the subagent only `git diff <base>...HEAD`, the prompt also
explained: which side of the conflict each branch owned, why the base's
signature change existed (a new dedup/convergence concept the merge had to
reconcile with), and the exact bug mechanism for the one-line fix (a
degenerate-input edge case). The subagent then targeted its checks at the named
risk points (return-value sourcing across every branch of a new dispatcher,
whether the one-line fix's guard condition changes behavriour anywhere else in
the file) instead of doing a generic line-by-line scan.

**Root cause:** A bare diff forces the reviewing subagent to reconstruct intent
from context clues before it can reason about correctness — cheap for a small
diff, but it means the reviewer spends its budget deriving "why" instead of
checking "is this right." Feeding the "why" directly (still verified against the
actual diff, never asserted unchecked) redirects that budget toward verification.

**Suggested fix:** When dispatching the Step 3 fresh subagent on a
merge-resolution or narrowly-scoped bugfix review, include a short prose
paragraph naming (a) which side of a conflict was kept and why, and (b) the
exact defect mechanism for a bugfix — then instruct the subagent to verify those
specific claims against the diff, not just hunt generically. Keep this to
genuinely narrow, mechanically-scoped reviews (a handful of files); a
large/organic diff still needs the generic adversarial sweep since no single
narrative covers it.
