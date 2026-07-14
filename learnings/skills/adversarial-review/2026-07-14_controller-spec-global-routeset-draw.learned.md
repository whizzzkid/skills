---
skill: wk-adversarial-review
date: 2026-07-14
type: surprise
severity: high
---

A named controller spec calling `routes.draw` mutates the global route table, silently breaking other specs later in the same process.

**What happened:** A `type: :controller` spec for a real (non-anonymous) controller redrew its route with `routes.draw { ... }`. This passed in isolation, but a request spec running later in the same process began returning `404` where it expected `401`. The route-drawing spec had wiped every other mount (admin/ops UI, etc.) for the rest of the process.

**Root cause:** In rspec-rails, `routes` defaults to the live `Rails.application.routes` singleton for a named controller (only anonymous `controller do ... end` specs get a throwaway RouteSet). `ActionDispatch::Routing::RouteSet#draw` clears the entire table before redrawing — so drawing one route on the global set deletes all others. The damage is order-dependent and invisible to a single-file run, so a green targeted run hides it.

**Suggested fix:** During the mechanical sweep, flag any `routes.draw` / `self.routes =` in a controller spec that is NOT an anonymous-controller block. The safe pattern is to draw into a fresh instance: `self.routes = ActionDispatch::Routing::RouteSet.new.tap { |r| r.draw { ... } }`. Add a cross-file check: when a spec mutates global framework singletons (routes, I18n, config), verify the suite still passes in a *different* order (or full-suite), never trust a single-file green.
