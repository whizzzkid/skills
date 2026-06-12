---
skill: wk-adversarial-review
date: 2026-06-11
type: pattern
severity: high
---

Truthy-but-unparseable input bypasses the fallback in a two-store redundancy pattern.

**What happened:** A method read a value from a primary store (metadata CLI), parsed it as an integer, and fell back to a secondary store (file) only when the primary returned nil. When the primary returned a non-nil but non-integer string, `Integer(raw, exception: false)` returned nil — but the `else` branch was unreachable because `raw` was truthy. The fallback was silently skipped.

**Root cause:** The branch condition checked the raw string (`if raw`) rather than the parsed result. The structure `if raw; Integer(raw); else; fallback; end` conflates "source responded" with "source returned valid data", defeating the redundancy.

**Suggested fix:** Add a sweep rule: when a method follows the pattern `if raw { parse(raw) } else { fallback }` where `parse` can return nil for valid non-nil inputs, flag it as a fallback-bypass bug. The correct pattern is `parsed = raw && parse(raw); parsed || fallback` so unparseable values from the primary store also trigger the fallback.

Pair with a test: stub primary to return an invalid (non-nil) value AND stub fallback to return a real value — assert the real value reaches the caller. Without this test, the contract is unverified.
