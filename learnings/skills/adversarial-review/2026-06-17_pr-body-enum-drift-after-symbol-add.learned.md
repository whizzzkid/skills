---
skill: wk-adversarial-review
date: 2026-06-17
type: gap
severity: medium
---

PR body enumerated lists (tags, reason symbols) not updated when new values are added in the same PR

**What happened:** A PR added a new enum value (:unexpected_error reason symbol) and a new
tag (event) to a metrics payload. The PR body's How section listed the old set of reason
symbols and tags. Sweep 2.8 caught this via the rename/enum-drift check, but only after
manual inspection — the signal was in the PR body, not in the diff.

**Root cause:** Sweep 2.8 says "Sync docs, READMEs, specs, tests, PR body, in-code help,
tables" but the trigger condition is "New/removed flags, symbols, errors, tests, docs terms."
When the diff adds a new symbol AND the PR body has an enumeration of those symbols, the
PR body enumeration is not explicitly checked against the new symbol list.

**Suggested fix:** Add to sweep 2.10 (PR body check): for each enum-like list in the PR
body (reason symbols, tag names, flag names, error codes) that names a set of values from
the diff, grep the post-diff production code for all current values and compare against
the PR body list. Any value in code but not in the PR body list is a drift signal.

## Additional evidence

Same pattern recurred in a follow-up refactor that split a single catch-all reason symbol
into 10+ granular symbols. The PR body still listed the old catch-all symbol and none of
the new ones. Sweep 2.8 caught it again. The fix was a `gh pr edit` (no commit needed —
PR body is GitHub metadata). Worth noting: a PR body update that doesn't touch code does
NOT require a new commit before the adversarial-review clears — it can re-verify the PR
body contents on the same HEAD SHA without resetting the cleared-sha record.
