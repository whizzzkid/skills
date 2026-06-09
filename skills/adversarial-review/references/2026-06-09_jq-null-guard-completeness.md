---
class: principle
skill: wk-adversarial-review
date: 2026-06-09
severity: medium
---

- **Rule:** When a `[ -z "$VAR" ]` guard reads `$VAR` from a `jq` filter,
  trace whether the filter can emit a non-empty falsy literal — `jq .field`
  emits the string `"null"` for a JSON null field, `"false"`/`"0"` for other
  falsy values — which an empty-string guard passes straight through.
- **Why:** Guard reachability ≠ guard completeness; `"null"` forwarded to a
  downstream SHA/API consumer is an invalid value the guard was meant to stop.
- **Where:** Sweep 2.3 (Reachability trace on new guards),
  "Guard-completeness probe (jq falsy output)".
