---
class: principle
---

# Multiple independent clock reads in one operation can straddle midnight

**Rule** — When a diff has ≥2 independent clock reads (`Date.current`,
`Date.today`, `Time.now`, `Time.current`, `time.Now()`, `Date.now()`) reachable
within one request/operation, flag it. Resolve the clock once at the entry point
and thread the value through. Blocker when the values gate a range boundary or
retention split; suggestion otherwise. (Sweep 2.77.)

**Why** — Each read looks locally correct; the bug exists only across call sites.
A window split into "past days from a capped rollup" + "today from a live store"
sees a different `today` per helper when the request crosses midnight, dropping
(or double-counting) the boundary day. No fixed-clock happy-path test catches it.

**Where** — `wk-adversarial-review` sweep catalog →
`references/sweep-catalog-extended.md` row 2.77.
