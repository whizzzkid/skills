---
class: principle
date: 2026-06-10
skill: wk-workflow
---

- **Rule:** When switching a consumer from a named-file lookup to a
  directory scan, grep the upstream producer and enumerate every file it
  writes; add an explicit include/exclude filter step.
- **Why:** A producer that emits extra files (e.g., a tarball beside
  individual binaries) gets published as an unintended entity when the
  scan assumes the directory holds exactly the expected set.
- **Where:** Phase 1, "Producer-audit probe".
