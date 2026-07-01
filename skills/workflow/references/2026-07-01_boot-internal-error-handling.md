---
class: principle
---

**Rule** — Code that runs at app boot/load, or reaches undocumented third-party internals (singletons, private monitors, constants), must ship its `rescue` + observability-notify in the first draft, not after a reviewer flags it. An existence-check (`respond_to?`) on one of several raising objects is not coverage. Wrap-and-continue unless a raise-and-halt is intentional.

**Why** — A boot-time fix called library-internal APIs guarded only by a `respond_to?` on one object; the other internal accesses could raise (undefined constant, nil receiver, missing method) and crash boot. Two review rounds were spent adding a rescue + notify that belonged in the first draft. The partial guard created false confidence the path was defended.

**Where** — `wk-workflow` Phase 2 Code Standards: "Boot / internal-symbol calls" bullet.
