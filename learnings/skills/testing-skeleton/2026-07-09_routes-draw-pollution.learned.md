---
skill: wk-testing-skeleton
date: 2026-07-09
type: gap
severity: medium
---

A `type: :controller` spec that calls `routes.draw { ... }` leaks a stripped route table into later `type: :request` specs unless it restores routes.

**What happened:** A controller spec redrew the application routes to register a probe action. It was green in isolation, but request specs for the real endpoints that ran after it got 404s — the app route table had been replaced by the probe's single route and never restored.

**Root cause:** `routes.draw` inside a controller example mutates the shared `Rails.application.routes` set. RSpec does not auto-restore it, so the pollution is invisible until another spec depends on the full route table; the failure is order-dependent (passes alone, fails when run after the polluting spec).

**Suggested fix:** Whenever a controller spec calls `routes.draw`, pair it with `after { Rails.application.reload_routes! }` to restore the real routes. Flag this in the testing-skeleton guidance for any spec that redraws routes.
