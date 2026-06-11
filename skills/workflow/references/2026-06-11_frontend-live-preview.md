---
class: principle
---

- **Rule** — On frontend (browser-rendered) diffs, launch the app and drive
  the changed views in a real browser via Playwright before Phase 4; hand the
  running session to the user, then continue the rest of the workflow without
  blocking on their manual test.
- **Why** — Unit tests miss render/layout/interaction regressions; the change
  ships unverified visually, and serial hand-off would stall the workflow on
  human review time.
- **Where** — New Phase 3.6 (Frontend Live Preview), between Phase 3.5 and
  Phase 4; also wired into the ASCII flow and the Plan Presentation step list.
