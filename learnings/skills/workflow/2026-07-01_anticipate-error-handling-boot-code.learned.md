---
skill: wk-workflow
date: 2026-07-01
type: gap
severity: high
---

Code reaching into third-party internals — especially at app boot — must ship with error handling and graceful degradation in the FIRST draft, not added later after a reviewer flags it.

**What happened:** A boot-time fix called library-internal APIs (a singleton, a monitor's unsubscribe) guarded only by a `respond_to?` check on ONE of the several objects touched. A reviewer flagged (Major) that the other internal accesses could raise (undefined constant, nil receiver, missing method) and crash app boot, with no rescue. Two review rounds were spent adding a `rescue` + error-notify that should have been there from the start. The user was frustrated the failure mode was not anticipated pre-write.

**Root cause:** Phase 2/3 (implement + sad-path testing) did not treat "these calls can raise, and this runs at boot" as a required sad-path. The `respond_to?` guard created false confidence that the path was defended.

**Suggested fix:** In Phase 2, when code (a) touches undocumented/internal third-party symbols or (b) runs at boot/load time, make "what raises here, and what happens to boot if it does" an explicit pre-write checklist item — wrap in `rescue` + observability notify and continue, unless a raise-and-halt is intentional. A partial guard (one object of many) is not coverage.
