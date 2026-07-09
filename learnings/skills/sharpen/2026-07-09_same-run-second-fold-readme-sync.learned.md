---
skill: wk-sharpen
date: 2026-07-09
type: gap
severity: low
---

A second fold into the same skill within one batch run trips `check-readme-sync` because the README `Version:` was already bumped by the first fold, leaving no README diff to stage.

**What happened:** Two learnings for the same skill were distilled in one batch run. The first fold bumped `metadata.version` + README `Version:` and committed. The second fold edited the SKILL.md again but the version was already at the run's CalVer, so `git add README.md` staged nothing — `check-readme-sync` blocked the commit ("SKILL.md changed without its README.md in the same commit").

**Root cause:** Step 8 / README-sync guidance assumes one version bump per skill per commit. It does not cover a same-run second edit where the version is already current, so there is no README change to satisfy the hook.

**Suggested fix:** In Step 7's README-sync rule, note that a same-run second fold into an already-bumped skill still needs a staged README change — sync a real narrative line reflecting the new edit (preferred), or the hook will block. Never re-bump the version for the second fold; add the narrative sync instead.
