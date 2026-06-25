---
skill: wk-adversarial-review
date: 2026-06-25
type: correction
severity: medium
---

Narrowing a regex to fix one concern (greedy overreach) can silently regress another dimension (paths with spaces) — verify both axes before accepting the fix.

**What happened:** A greedy regex `.+\.json` was changed to `[^ ]+\.json` (non-whitespace chars only) to fix potential trailing-content capture. The narrowing broke path extraction for any path containing a space — the `[^ ]+` anchor cannot bridge the space, so the entire match fails silently and the extraction returns empty.

**Root cause:** The fix was evaluated only against the greedy-overreach scenario, not against the space-in-path scenario. The original regex handled spaces by being greedy; the replacement excluded them explicitly.

**Suggested fix:** Before accepting a regex-narrowing fix, enumerate the full input space: does the original regex handle edge cases (spaces, Unicode, special chars) that the narrowed form loses? Prefer restructuring with `sed -n 's/.*anchor → //p'` (extracts tail-of-line, handles all chars) over character-class exclusions when the path format is unconstrained.
