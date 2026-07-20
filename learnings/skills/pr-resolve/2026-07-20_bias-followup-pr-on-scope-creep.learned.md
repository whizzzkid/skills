---
skill: wk-pr-resolve
date: 2026-07-20
type: gap
severity: medium
---

When a review finding's fix would expand a PR's scope, strongly bias toward a follow-up PR instead of building it inline.

**What happened:** On a narrow, stacked ("Part N/M") PR, a correctly-dismissible race-condition finding (a check-then-write TOCTOU that was already backstopped by an existing reconcile job) was upgraded mid-resolution into a full new concurrency mechanism — a deferred-write-through system with new keys, lock ordering, snapshot partitioning, and its own spec suite — roughly doubling the PR's size. Separately, re-reviewing the session's own fixes kept surfacing adjacent findings that begat more fixes (a self-feeding loop), compounding the drift. The PR started as "a simple change" and ended far larger than its stated scope.

**Root cause:** The skill triages each finding on correctness/severity but has no explicit gate on *fix size vs. PR scope*. An "accepted" disposition silently authorizes arbitrarily large inline work. There is no checkpoint that asks "is this fix a localized patch, or a new mechanism/feature/design change?" before implementation, so a dismissible-or-deferrable finding can be quietly built out in place.

**Suggested fix:** In Step 4/5 (suggestion + consult), classify each accepted finding by *fix footprint*, not just severity. When a fix is more than a localized patch — a new mechanism/feature, a design change, or cross-cutting work — default to **dismiss-with-rationale + track a follow-up PR** rather than building it inline, especially on stacked or explicitly-narrow PRs. Only build inline when it's a confirmed blocker for THIS PR's stated scope. Add an explicit scope guard before implementing any non-trivial fix, and treat "my own re-review surfaced a new adjacent finding" as a strong signal to defer, not to keep expanding the current PR.
