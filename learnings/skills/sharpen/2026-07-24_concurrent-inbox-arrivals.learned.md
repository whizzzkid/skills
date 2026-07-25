---
skill: wk-sharpen
date: 2026-07-24
type: gap
severity: medium
verified-against-source: yes
---

The re-scan rule cannot distinguish a drained inbox from one being actively written by a concurrent
sharpen agent in the same working tree.

**What happened:** Batch mode says to re-scan after each fold-commit and to treat "inbox drained" as
a terminal check rather than a fact set up-front. At run start the queue held exactly two learnings,
both for this skill; both were folded, committed, and pushed. The post-commit re-scan then surfaced
four items that had not existed at start — three learnings for other skills plus a retrospect — with
mtimes a few minutes after the run began. The commit log showed sibling sharpen commits landing
across many skills every few minutes, and a dozen-plus sibling sharpen agents were listed as active
in the same shared working tree. Read literally, the rule directs the agent to fold those arrivals
now. Doing so would mean editing skill files a sibling may be mid-fold on, with no lock, lease, or
ownership marker anywhere in the flow to detect it. The run stopped and reported them as unclaimed
backlog instead, explicitly declining to claim the inbox was drained.

**Root cause:** The re-scan rule was written against a single-agent tree, where a new arrival can
only mean new work for this run. It encodes no notion of provenance for an arrival, so a file written
by a peer is indistinguishable from one the dispatcher intended for this run. Two consequences of
processing a peer's arrival — clobbered concurrent edits and conflicting version bumps in the same
file — are *inferred*, not observed; no collision actually occurred, because processing was declined.
What is directly verified is the churn itself: the arrival mtimes postdate the run start, and the log
shows concurrent sharpen commits. A second, independent gap: the dispatching agent asserted that no
siblings were editing files and that a collision check was unnecessary, and the tree state falsified
that assertion — nothing in the flow says an agent's claim about tree state loses to observation.

**Suggested fix:** Distinguish a drained inbox from a churning one before processing a re-scan
arrival. Treat an arrival whose mtime postdates the run's start as unowned rather than assigned, and
corroborate with recent commit activity on the tree; when either signal shows a concurrent writer,
report the item as unclaimed backlog for the dispatcher and do not fold it, since no ownership
primitive exists to arbitrate. Report the terminal state honestly as "processed N, M unclaimed
arrivals" rather than "drained". Separately, state that a dispatcher's claim of exclusive access is
a hypothesis about tree state like any other and does not survive contradicting evidence from the
tree — the same discipline the report-is-hypothesis rule already applies to a field report's root
cause.
