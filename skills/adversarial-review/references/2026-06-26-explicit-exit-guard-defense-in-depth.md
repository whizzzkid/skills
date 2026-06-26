---
class: principle
---

**Rule:** An explicit `|| { exit; }` guard placed after a type-check that
already aborts (e.g. `jq -e 'type == "array"'`) is the failure-surfacing remedy
itself, not a new dead guard. Classify it suggestion/question, note it is
defense-in-depth, and confirm intent before removing — never blocker.

**Why:** A dead `${var:-default}` fallback is a blocker because it silently
documents an unreachable path; replacing it with an explicit `|| exit` makes
intent clear. Flagging that explicit guard as a blocker would contradict the
recommended fix.

**Where:** Pre-push checklist row 2.3 (new guard / null-check / defensive branch).
