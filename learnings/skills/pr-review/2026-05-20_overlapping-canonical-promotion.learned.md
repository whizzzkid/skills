---
skill: wk-pr-review
date: 2026-05-20
type: pattern
severity: medium
---

Playground caught overlapping canonical promotion in proximity-chain clustering

**What happened:** Phase 4 playground revealed that a Pass 2 promotion loop
using a proximity-based dedup guard on the *entry key* (not the *canonical
key*) can produce multiple overlapping canonical entries in `permanent` when
resolved comments form a chain longer than the proximity window. Entries in
reversed/non-sequential iteration order exposed a case where the guard
(`promoted.any? { |p| p.matches?(entry_key) }`) passes for an entry far from
an existing promoted canonical, yet the cluster's chosen canonical (max-id
member) falls within proximity of that existing canonical.

**Root cause:** Dedup ran on iteration anchor, not on the final canonical.
The two differ whenever the cluster's highest-id member is not the anchor
entry itself.

**Suggested fix:** In the skill investigation guidance, explicitly prompt
checking dedup-guard logic when reviewing promotion algorithms that select a
*representative* from a cluster — the guard and the representative may be at
different coordinates, causing silent overlap. A single playground experiment
(iterating entries in reverse order) is sufficient to expose this class of
bug in O(n²) cluster-forming loops.
