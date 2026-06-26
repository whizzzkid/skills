---
skill: wk-adversarial-review
date: 2026-06-26
type: pattern
severity: low
---

Bot re-fires on same dismissal class from new angles across CI rounds — all remain valid dismissals.

**What happened:** After a round where "cleanup-pattern repetition" was dismissed (2-line inline idiom acceptable), the bot returned on the next CI run with four new Minor findings that all fell into the same two concern classes: (1) simplicity/helper-extraction for the same function's error paths, (2) cleanup redundancy with the EXIT trap. The new angles were slightly different ("extract abort_query()" vs "the pattern is inline") but the underlying decision was the same.

**Root cause:** The bot evaluates each finding against the current diff independently per run. A dismissal in round N doesn't inform round N+1 — the bot has no session-level memory of prior decisions. When code grows (a new helper is extracted), the bot's structural analysis runs fresh and may re-surface the same concern class with new framing.

**Suggested fix:** In the Step 4 "Surface prior-round dismissals" instruction, add: when a bot re-fires on the same concern class from a new angle and the prior dismissal rationale still applies structurally, surface the prior reason inline and default to `(d)` without re-presenting as judgment-required. Track dismissed concern classes by `(check_name, concern_class)` tuple across rounds, not just by `(path, line)`.
