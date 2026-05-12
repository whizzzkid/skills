---
date: 2026-05-12
slug: dependency-install-after-base-change
---

- **Rule:** Re-install dependencies after integration when the lockfile differs between pre- and post-integration base.
- **Why:** A bumped dependency in the base produces a "missing dependency" failure during validation that mimics a real test regression.
- **Where:** Stage 5 → "Dependency install pre-check" sub-section.
