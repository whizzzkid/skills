---
skill: wk-sharpen
class: principle
---

**Rule** — In batch mode, an inbox item whose mtime postdates the run's start is
**unowned, not assigned**. Corroborate with commit recency on the tree; when either
signal shows a concurrent writer, report the item as unclaimed backlog for the
dispatcher and do not fold it. Report the terminal state as "processed N, M unclaimed
arrivals", never "drained".

**Why** — The re-scan rule was written for a single-agent tree, where a new arrival can
only mean new work for this run. It encodes no provenance, so a file written by a peer
sharpen agent is indistinguishable from one the dispatcher intended for this run — and
no lock, lease, or ownership marker exists anywhere in the flow to arbitrate. What is
directly observed is the churn (arrival mtimes postdating run start, concurrent sharpen
commits in the log); clobbered edits and conflicting version bumps are the inferred
consequences of folding a peer's arrival, not observed ones.

**Corollary** — A dispatching agent's assertion about tree state ("no peer is mid-fold",
"skip the collision check") is a hypothesis subject to the same
report-is-a-hypothesis discipline as a field report's root cause: it does not survive
contradicting evidence from the tree.

**Where** — wk-sharpen batch mode, Source 2 re-scan rule; corollary folded into the
Step 1 verify-against-the-owning-source HARD RULE.
