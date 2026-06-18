---
class: principle
skill: wk-adversarial-review
date: 2026-06-18
---

**Rule:** Do not dismiss a nil-guard on a map field populated via
`json.Unmarshal` as dead code without confirming the JSON schema always carries
the key. Go's `json.Unmarshal` leaves a map field `nil` when the key is absent
from the payload (absent key ≠ empty object `{}`), even when the surrounding
struct unmarshals without error. The guard is load-bearing for the absent-key
path.

**Why:** A bot flagged `if decoded.MapField == nil { return error }` as dead,
conflating "extraction succeeded" with "the target key was present." A missing
map key produces `nil` silently, not an unmarshal error — the nil branch is a
valid, testable path.

**Where:** Step 2 sweep 2.3 (guard reachability) and Step 3 absence-claim-cautious
— a reachable absent-key path is not a dead guard.
