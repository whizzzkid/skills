---
skill: wk-adversarial-review
date: 2026-06-26
type: pattern
severity: low
---

A `${var:-default}` default applied after a guard that would have already aborted on the failure path is misleading dead code.

**What happened:** A function validated a JSON value with `jq -e 'type == "array"'` (aborting on non-array), then computed `count=$(jq 'length')` and used `${count:-0}` as if jq might return empty. The `:-0` default is unreachable: if the type guard passed, jq on a valid array cannot return empty; if jq failed, `set -e` would have killed the script before reaching the default. The pattern looks like resilience but documents a failure path that cannot happen.

**Root cause:** Defensive `:-default` patterns are habitually applied without checking whether upstream guards have already made the fallback unreachable.

**Suggested fix:** Flag `${var:-fallback}` patterns where the preceding guard (a type check, `set -e` abort path, or `|| exit`) makes the fallback structurally unreachable. Report as a suggestion: either drop the dead default, or add explicit error handling that actually surfaces the failure with a message.
