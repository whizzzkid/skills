---
class: principle
---

**Rule** — Sweep 2.74: flag a spec that mutates a global framework singleton — Rails
`routes.draw` / `self.routes =` in a NON-anonymous controller spec, or `I18n`, global
config, registered enums. Require the safe pattern (draw into a fresh `RouteSet.new`) and
a suite run in a DIFFERENT order (or full-suite); never trust a single-file green.

**Why** — `ActionDispatch::Routing::RouteSet#draw` clears the whole table before
redrawing, and a named-controller spec's `routes` defaults to the live
`Rails.application.routes` singleton — so drawing one route wipes every other mount for
the rest of the process. The breakage is order-dependent and invisible to a single-file
run.

**Where** — `references/sweep-catalog-extended.md` row 2.74; inline pointer list in
`SKILL.md`; README count 78→80 (with 2.75).
