---
class: principle
---

- **Rule** — Every SKILL.md `metadata.version` bump bumps a `**Version:**`
  line in the sibling `README.md` to the same CalVer; the README is staged in
  the same commit as the SKILL.md.
- **Why** — README and SKILL.md drift apart silently otherwise; a reader
  trusting the README sees a stale version and stale described behavior.
- **Where** — Step 7 "Sync skill README" sub-section (version-bump bullet);
  enforced by the new `check-readme-sync` pre-commit hook (co-staging).
- **Note** — `check-readme.sh` only checked README *existence*; the new
  `check-readme-sync.sh` requires *co-staging* on every SKILL.md change.
  Existing READMEs gain the Version line lazily as each skill is next sharpened
  (the hook checks co-staging, not the line's presence, so no mass retrofit).
