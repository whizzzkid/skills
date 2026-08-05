---
class: principle
---

# Secret consumption does not imply provisioning ownership

**Rule** — Before creating a workstream for a runtime secret, identify who
provisions it and whether provisioning is repository automation, an external
platform responsibility, or a manual operator action. Manual population is an
operational prerequisite, not evidence that infrastructure code is in scope.

**Why** — Conflating consumption with provisioning expands plans into systems
the repository does not own and turns a documented setup step into invented
implementation work.

**Where** — `SKILL.md` → Step 2.5 → Secret-ownership probe, with a matching
Step 4 validation item.
