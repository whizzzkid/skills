---
skill: wk-pr-resolve
date: 2026-06-17
type: pattern
severity: low
---

When a bot fires on the same field a second time from a different angle and a prior dismissal exists, surface the prior decision and default to dismiss.

**What happened:** A struct field was flagged as "unused" in one review round and dismissed by the user ("keep for future use cases"). In a later push, a different bot finding flagged the same field as "redundant" — a different framing of the same underlying suggestion. The agent presented it as judgment-required without noting the prior dismissal, requiring the user to re-state the same reasoning.

**Root cause:** Step 4 tracks multi-bot convergence in the *same* review cycle, but does not check prior-round decisions when a new bot fires on a previously dismissed field/concern. The user had to re-explain the design decision rather than simply confirming it.

**Suggested fix:** Before presenting a judgment-required finding, grep the current session's `dismissed` list and prior-round notes for the same field or concern class. If a prior dismissal exists on the same field: surface it inline ("Note: in a prior review round, you dismissed a similar finding on this field — {reason}"), present `(d)` as the obvious default, and ask once to confirm or override rather than presenting all options equally.
