---
date: 2026-05-12
slug: upstream-source-fallback
---

- **Rule:** Fetch framework source from the upstream repo via `gh api ... contents` + base64-decode when the local bundle is broken; replicate framework logic verbatim in a standalone script when the app cannot boot.
- **Why:** Worktree review environments routinely lack a full install or bootable app; abandoning the review path on every install failure costs coverage that the upstream source could provide trivially.
- **Where:** Phase 3 → "Read framework source when local install is unavailable"; Phase 4 → "Standalone playground when the app cannot boot".
