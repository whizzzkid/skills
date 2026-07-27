---
class: principle
skill: wk-workflow
---

# CI fix-candidate ordering

Relocated from `SKILL.md` (Phase 6: CI Fix Loop) to hold the body under the size
ceiling. The ranked order stays inline there; these are the per-candidate notes.

Try candidates in order — least invasive first. Never skip ahead to a
tool-stack change because it looks like the "real" fix.

| Priority | Candidate | Notes |
|---:|---|---|
| 1 | Version downgrade | One minor/patch when a dep upgrade is the proximate cause |
| 2 | Repo-rule compliance | Usually a one-line config change |
| 3 | Same-tool config tweak | Tool config before tool swap |
| 4 | Same-tool backend/option change | Backend, installer flag, or runner option within the existing tool |
| 5 | Tool-stack change | Removing/replacing a user-named tool requires explicit confirmation |
