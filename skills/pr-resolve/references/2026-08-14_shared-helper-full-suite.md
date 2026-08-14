---
class: principle
source: learnings/skills/pr-resolve/2026-08-14_full-suite-post-refactor.md
date: 2026-08-14
---

## Shared-helper refactor demands full-directory verification

Targeted spec runs after extracting shared logic into a helper method missed a
semantic inversion that broke 20+ callers. Only files directly touching the helper
were verified; the full spec directory was not exercised.

**Principle:** Any commit that adds, renames, or alters the contract of a method
called from ≥2 sites → run the full spec/test directory containing all call sites.
Narrow verification is only safe for changes localized to a single file's own logic.

**Landed in:** Step 6, sub-step 2 — shared-helper verification sub-bullet.
