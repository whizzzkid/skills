---
skill: wk-adversarial-review
date: 2026-06-26
type: pattern
severity: low
---

A `|| { exit 1; }` guard on `jq 'length'` after a `jq -e 'type == "array"'` type-check is defense-in-depth, not a reachable bug fix.

**What happened:** After a `jq -e 'type == "array"'` guard (which aborts on non-array/malformed JSON), a `count=$(jq 'length' "$file")` was wrapped in `|| { ... exit 1; }` to handle jq crashes. The adversarial subagent correctly noted the guard is unreachable in practice — once a valid array is confirmed, `jq 'length'` cannot fail — but accepted it as defensible defense-in-depth.

**Root cause:** The original code's `${count:-0}` fallback was similarly unreachable; replacing it with an explicit `|| exit` guard made the intent clear without adding reachable logic.

**Suggested fix:** When reviewing a `|| { exit; }` guard after a type-check that already aborts on failure, classify it as suggestion/question (not blocker), note it is defense-in-depth, and confirm intent before removing.
