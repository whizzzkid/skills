---
date: 2026-05-12
slug: intra-file-duplication-probe
---

- **Rule:** Before adding a new function/handler/initializer to a large mixed-content file (>200 lines, especially templates), grep the file itself for the feature keyword first.
- **Why:** A stale or partial prior version can silently shadow the new code; tests pass when the right copy wins and corrupt behavior when the wrong copy does.
- **Where:** Phase 1 → "Intra-file duplication probe" sub-section under the prefactor probe.
