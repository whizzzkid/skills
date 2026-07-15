---
skill: wk-adversarial-review
date: 2026-07-15
type: pattern
severity: medium
---

Env vars parsed with `String#to_i` silently coerce malformed input to 0, hiding operator misconfiguration — and a 0 is often a semantically loaded value (kill-switch, "unlimited", "disabled").

**What happened:** A config module read three integer thresholds via `ENV.fetch(KEY, DEFAULT).to_i`. A reviewer flagged that a malformed value (e.g. `"fifteen"`) becomes `0` with no warning; for the ceiling threshold, `0` was the documented kill-switch, so a typo would silently disable the whole feature.

**Root cause:** `String#to_i` never raises — it parses the leading numeric prefix and returns `0` for a fully non-numeric string. When `0` is a meaningful boundary in the surrounding logic, the failure is invisible: no exception, no log, just a feature quietly turning off.

**Suggested fix (detection sketch):** When reviewing config/env parsing, grep for `.to_i` / `parseInt` / `atoi` on external input and ask "what does 0 mean here?" If 0 is load-bearing (disable, unlimited, kill-switch), require strict parsing that distinguishes malformed from zero — e.g. Ruby `Integer(raw, 10)` with `rescue ArgumentError` → warn + explicit fallback. Prefer matching an existing strict-parse helper already in the repo over inventing a new pattern. Confidence: high — this is a recurring, mechanically-detectable class.
