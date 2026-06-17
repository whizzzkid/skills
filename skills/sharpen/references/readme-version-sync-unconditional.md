---
skill: wk-sharpen
class: principle
---

**Rule** — On every `metadata.version` bump, bump the sibling `README.md`
`Version:` line to the same CalVer and stage it in the same commit —
unconditionally, even when no step/diagram/narrative changed.

**Why** — `.githooks/check-readme-sync.sh` rejects any commit that stages a
`SKILL.md` without its sibling `README.md`. Framing the README touch as
conditional on a narrative change leads to a version-only edit skipping the
README and getting blocked at commit, forcing a second pass.

**Where** — Step 7 "Sync skill README" and the Drift check.
