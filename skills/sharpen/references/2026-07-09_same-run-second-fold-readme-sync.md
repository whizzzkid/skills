---
class: one-off
skill: wk-sharpen
date: 2026-07-09
severity: low
---

- **Scenario:** Two learnings for the same skill are distilled in one batch run.
  The first fold bumps `metadata.version` + the README `Version:` and commits.
- **Symptom:** The second fold edits the same SKILL.md, but the version is already
  at the run's CalVer, so `git add README.md` stages no diff — `check-readme-sync`
  blocks the commit ("SKILL.md changed without its README.md in the same commit").
- **Fix:** On a same-run second fold into an already-bumped skill, do NOT re-bump
  the version (CalVer is per-run). Instead stage a real README narrative change
  reflecting the new edit — a one-line behavior note — so the sibling README is
  part of the commit and the hook passes.
- **Why not promoted:** Fires only under a rare configuration (two folds into the
  same skill within one run). The common-case rule (bump + stage README on every
  version change) already lives in Step 7's README-sync block, and wk-sharpen is
  at its size ceiling; inlining a narrow edge-case workaround is not worth the
  reclaim.
