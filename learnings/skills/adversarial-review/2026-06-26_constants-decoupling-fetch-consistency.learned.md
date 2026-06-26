---
skill: wk-adversarial-review
date: 2026-06-26
type: pattern
severity: medium
---

Separate constants for different concerns (visibility vs approval gate) prevent bot thrash when the two lists diverge; `.fetch` consistency at partition time surfaces nil early.

**What happened:** Introducing VISIBLE_SEVERITIES alongside BLOCKING_SEVERITIES stopped repeated bot re-firing on a "don't reuse the same constant for two concerns" finding. Using `finding.fetch("severity")` in the partition predicate (high_severity_finding?) rather than bracket access ensures nil severity raises at the earliest call site instead of silently routing to a collapsed section and crashing later in a formatter.

**Root cause:** Sharing one constant for visibility and approval gates conflated two independent concerns; bracket access for nil-able fields deferred errors past the decision point.

**Suggested fix:** When a predicate and a gate share a field, check whether they need independent constants even if values are identical today. Use `.fetch` over bracket access in predicates that partition data — fail-fast at the decision boundary beats a downstream crash.
