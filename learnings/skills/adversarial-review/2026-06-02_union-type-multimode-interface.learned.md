---
skill: wk-adversarial-review
date: 2026-06-02
type: gap
severity: low
---

Flag flat union/struct types that serve multiple distinct consumer modes in spec interfaces.

**What happened:** A bot reviewer caught (and the pre-flight adversarial review missed) that a spec's
label struct was a flat union spanning four evaluation modes — different consumers read disjoint subsets
of fields. The concern: as modes grow, every consumer accumulates nil-guards for inapplicable fields, and
compatibility is implicit rather than declared.

**Root cause:** The adversarial sweep checks code-level correctness (sibling fixes, dead guards, stale
comments) but has no lens for *interface abstraction smell* in design docs — a single type whose fields are
only conditionally meaningful depending on which consumer/mode reads it.

**Suggested fix:** Add a judgment-level lens to the subagent critique (and a light heuristic to the
mechanical sweep) for spec/interface diffs: when a struct/union/record type's fields are consumed by
multiple distinct modes or consumer families where each reads only a subset, flag it as `suggestion` and
ask whether compatibility should be explicit (consumer declares the fields it requires, or producer
declares which consumers it supports) rather than relying on every consumer to tolerate missing fields.
Detection sketch (heuristic, judgment to confirm): in a diff that defines a struct/union with ≥4 fields
where comments or prose tie subsets of fields to different modes/consumers, surface the multi-mode union
for review. Confidence: judgment (requires reasoning about consumer access patterns, not a pure grep).
