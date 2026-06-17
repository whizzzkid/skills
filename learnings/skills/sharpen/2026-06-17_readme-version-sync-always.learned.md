---
skill: wk-sharpen
date: 2026-06-17
type: gap
severity: low
---

A version-only SKILL.md edit must still bump the sibling README's Version line, or the commit is blocked.

**What happened:** Sharpened a skill with an internal-only code fix (no
step/flow/description change). Bumped `metadata.version` in SKILL.md, judged the
README body unaffected, and staged without touching README.md. The
`check-readme-sync` pre-commit hook rejected the commit: "SKILL.md changed
without its README.md in the same commit." Required a second pass to bump the
README Version line and re-commit.

**Root cause:** Step 7's "Sync skill README" rule frames README updates as
conditional on step/phase/trigger changes, so a body-unchanged edit reads as
"README sync not needed." But the hook enforces an unconditional invariant: any
staged SKILL.md change requires its sibling README.md staged too, with a matching
Version line — independent of whether the README narrative changed.

**Suggested fix:** Make the README version bump unconditional in Step 7 / the
Drift check: whenever `metadata.version` changes, bump the sibling README's
`Version:` line to the same CalVer and stage it in the same commit — even when no
narrative/diagram/step changed. State that `check-readme-sync` blocks any
SKILL.md commit lacking its sibling README.
