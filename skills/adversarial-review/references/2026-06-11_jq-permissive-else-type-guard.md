---
class: principle
date: 2026-06-11
skill: wk-adversarial-review
---

- **Rule:** Flag an added jq `else . end` (not `else empty`) in a
  type-dispatch expression — verify every unlisted input shape produces
  acceptable `jq -r` output.
- **Why:** A bare `else .` passes objects through; `jq -r` renders them as
  multi-line pretty-printed JSON (garbage output) — a structural unguarded
  passthrough the reachability sweep (2.3) misses.
- **Where:** Sweep 2.31 (jq permissive `else .` passthrough). Safe pattern:
  `if type=="array" then .[] elif type=="string" then . else empty end`.
