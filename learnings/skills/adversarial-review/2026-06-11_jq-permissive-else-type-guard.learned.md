---
skill: wk-adversarial-review
date: 2026-06-11
type: gap
severity: medium
---

When auditing a jq `if type=="array" then .[] else . end` fix, flag the `else` branch as a data-leak risk unless it is restricted to `elif type=="string"`.

**What happened:** A fix for silent data loss (jq `[]?` suppressing non-array inputs) used the pattern `if type=="array" then .[] elif . == null then empty else . end`. The `else . end` branch passes any non-null, non-array value through — including objects, which jq -r renders as multi-line pretty-printed JSON, producing garbage bullets in the output. The adversarial subagent caught this; the fix was tightened to `elif type=="string" then . else empty end`.

**Root cause:** Sweep 2.3 traces guard reachability and completeness for empty-string guards, but does not probe `jq if-elif-else` dispatch expressions for permissive `else` branches. A fix that adds an `else . end` fallback in a jq type-dispatch expression is structurally equivalent to an unguarded passthrough for unexpected input shapes — the adversarial subagent caught it, but the mechanical sweeps missed it entirely.

**Suggested fix:** Add a mechanical sweep for jq `else . end` in added/modified diff lines: when `else .` appears in a jq expression (not `else empty`), flag it as a candidate for review — the caller should verify that all non-listed types produce acceptable output when passed through `jq -r`. The canonical safe pattern for string-only extraction is `if type=="array" then .[] elif type=="string" then . else empty end`.
