---
skill: wk-adversarial-review
date: 2026-06-09
type: gap
severity: medium
---

Sweep 2.3 (guard reachability) must trace jq filter output shapes, not just the existence of a guard.

**What happened:** A new `[ -z "$SHA" ]` guard was introduced to handle missing SHA output from `gh pr view | jq`. The guard passed the 2.3 trace (guard exists, guard is reachable) but the trace did not check jq's documented behavior: when the JSON field is present but null, `jq .field` emits the literal 4-character string "null", not an empty string. The empty-string guard passes for "null", silently forwarding an invalid SHA to the downstream API call.

**Root cause:** Sweep 2.3's reachability trace checks whether the guard can fire (is the conditional reachable), not whether the guard captures all forms of the invalid sentinel (is the guard complete). jq null-output is a well-known edge case that the trace should probe explicitly.

**Suggested fix:** Add a jq-null-output probe to 2.3: when a guard tests `[ -z "$VAR" ]` and `$VAR` is populated from a `jq` filter, check whether the filter can emit the string "null" (JSON null fields) or "false"/"0" (other falsy JSON values). Detection: grep for `jq` pipes feeding variables guarded with `[ -z ... ]`.
