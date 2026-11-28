---
class: principle
skill: wk-renovate
date: 2026-11-27
severity: medium
---

# Regenerate vendored copies a lockfile-only bump invalidates

**Rule** — Per bumped package, read the original Dependabot PR's failing CI log first, then grep the repo for vendored
copies of that package. Found → run the package's own regenerate command, confirm its validate command passes, and
commit the regenerated file with the bump.

**Why** — Dependabot rewrites only the lockfile and never runs a package's regeneration step. A repo that vendors a
file from the package (loaded before dependency install) and a validator that rejects a copy differing from the
installed version turn CI red. Confirmed from the red CI log and by running validate before and after regeneration.

**Folded with** — `2026-11-27_review-before-ready.md` (the same report's review-timing note).

**Where** — `SKILL.md` → Step 4.
