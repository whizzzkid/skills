---
class: principle
---

**Rule:** When computing the one-pass reclaim quantity at tight headroom, derive the estimate from a structural move (subsection merge, scaffolding/blank-line deletion) whose byte count is countable before editing. Treat prose compression as the unreliable final-margin only — never the primary planned quantity.

**Why:** Prose-compression byte savings are unpredictable — tightening one line can save anywhere from tens to 100+ bytes depending on wording, so an estimate sized from prose under-shoots and reopens the very over → trim → over → trim search loop the byte-budget rule forbids. Structural moves reclaim a fixed, countable quantity in one pass.

**Where:** Step 7.5, single-digit/tight-headroom byte-budget sub-bullet.
