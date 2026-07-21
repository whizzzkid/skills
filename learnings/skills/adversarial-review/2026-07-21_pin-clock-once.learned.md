---
skill: wk-adversarial-review
date: 2026-07-21
type: gap
severity: medium
---

Multiple independent `Date.current`/`Time.now` reads in one request can straddle midnight and silently drop the boundary day.

**What happened:** A read endpoint split a windowed count into "past days from a rollup (capped at today-1)" and "today from a live store". Each helper called `Date.current` independently. A request crossing midnight sees today=N in the rollup helper (capping at N-1) and today=N+1 in the live helper (whose `range.cover?(today)` then misses day N) — day N is dropped from both. Caught by a reviewer, not by the mechanical sweeps.

**Root cause:** No sweep flags repeated clock reads within a single logical operation. Each `Date.current` looked locally correct; the bug only exists across call sites.

**Suggested fix:** Add a sweep row: when a diff has ≥2 `Date.current` / `Date.today` / `Time.now` / `Time.current` reads reachable within one request/operation, flag it — resolve the clock once at the entry point and thread the value through. Severity blocker when the values gate a range boundary or retention split (a divergence drops/double-counts data); suggestion otherwise.
