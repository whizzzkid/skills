---
skill: wk-adversarial-review
date: 2026-06-18
type: surprise
severity: medium
---

Bot false positive: nil map check after json.Unmarshal is valid when the JSON key can be absent.

**What happened:** A {bot} flagged `if decoded.MapField == nil { return error }` as dead code, reasoning that a prior extraction step would have returned an error before reaching the check. The bot was wrong: Go's `json.Unmarshal` leaves a map field `nil` when the JSON key is entirely absent from the payload (absent key ≠ empty object `{}`), even when the surrounding struct unmarshals without error.

**Root cause:** The bot conflated "extraction succeeded" with "the target key was present in the JSON." In Go, a missing map key silently produces `nil`, not an unmarshal error. The nil check is load-bearing for the absent-key path, not dead.

**Suggested fix:** When reviewing a nil-guard on a map field populated via `json.Unmarshal`, verify whether the JSON source can omit the key entirely (as opposed to providing an empty object). Absent-key → nil is a valid, testable path in Go; do not dismiss the guard as dead without confirming the key is always present in the payload schema.
