---
skill: wk-sharpen
date: 2026-07-25
type: gap
severity: medium
verified-against-source: yes
---

"A blocked commit gate defers a MUST-FOLD item" needs a path-state qualifier: the harm is
opening a *new* uncommittable fold, not extending one that already exists.

**What happened:** With the commit gate blocked, a severity-high MUST-FOLD item arrived
whose subject was owned by two skills that already carried prepared, uncommitted folds. The
ownership rule says a blocked gate "defers a MUST-FOLD item rather than folding harder —
an unlandable fold entangles a shared tree," read literally that forbids all folding. But
the paths in question were already dirty and already unlandable, so extending them added no
new entanglement, while a third candidate skill sat on a clean unclaimed path where folding
*would* have opened a fresh uncommittable fold. The two cases warrant opposite calls, and
the rule as written does not distinguish them.

**Root cause:** The rule states its remedy (defer) absolutely but states its rationale
(entanglement of a shared tree) conditionally. Entanglement is a property of the *target
path's* state, not of the gate's state: extending an already-dirty path is a no-op against
the stated harm. Because only the remedy is unconditional, the rule reads as a blanket
prohibition and would strand high-severity items for as long as signing stays down — while
the same run is already permitted to leave other folds sitting in the tree.

**Suggested fix:** Qualify the deferral by target-path state. Blocked gate + target path
already carries an uncommitted fold → extend that fold and advance its single version bump,
never open a competing one. Blocked gate + clean unclaimed target path → defer, and report
the item as blocked backlog rather than folding. Make the rationale the test: fold only
where it adds no path that was not already uncommittable.
