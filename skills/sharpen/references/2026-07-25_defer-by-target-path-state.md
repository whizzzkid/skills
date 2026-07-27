---
class: principle
---

# A blocked commit gate defers by target-path state, not gate state

**Rule** — Blocked gate + target path already carrying an uncommitted fold → extend that
fold and advance its single version bump, never open a competing one. Blocked gate + clean
unclaimed target path → defer and report the item as blocked backlog. The test is the
rationale: fold only where it adds no entanglement the path did not already carry.

**Why** — The prior wording stated its remedy (defer) absolutely while stating its rationale
(entanglement of a shared tree) conditionally. Entanglement is a property of the *target
path's* state, not of the gate's state — extending an already-dirty, already-unlandable
path is a no-op against the stated harm. Because only the remedy was unconditional, the
rule read as a blanket prohibition that would strand high-severity items for as long as
signing stays down, while the same run is already permitted to leave other folds in the
tree.

**Verified against source** — Confirmed the blanket clause was in force before drafting: it
is present verbatim in *both* the installed skill and the worktree, so the newly added
installed-vs-worktree precondition does not excuse it. Confirmed the two-case split is real
in this run's tree — the owning skill's path already carried an uncommitted fold (extended
it), while a separately-queued item's target path was clean under `git status --short`,
with a positive control on a known-dirty path proving the query form fires.

**Consequence for a deferred item** — A queue entry deferred under the old blanket rule does
not automatically release when the rule is qualified. Re-judge it by its own target path: a
clean path keeps the defer, now for a stated reason rather than a blanket one.

**Classification** — `principle`. Generalizes to any multi-run shared tree where a gate
failure is global but dirtiness is per-path.

**Escalation** — None. The ownership rule's remedy was under-qualified from the start; no
existing rule fired and failed.

**Where** — `SKILL.md` → "high-severity learnings are not optional", ownership bullet.
