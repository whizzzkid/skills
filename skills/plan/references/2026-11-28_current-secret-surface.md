---
class: principle
---

# Name the current secret-management surface before quoting a command

**Rule** — Before telling an operator how to set a runtime secret, name the platform's current secret-management
surface. A set-secret CLI copied from a generator doc, README, or scaffold template is unverified until checked
against current practice; when it cannot be confirmed, ask instead of quoting it.

**Why** — Secret tooling migrates (a repo-local CLI gives way to a central management surface) while generated docs
keep the old command. Quoting it unchecked sends the operator down a retired path and reads as an authoritative
instruction.

**Where** — `SKILL.md` → Step 2.5 → Secret-ownership probe (extends
[`2026-08-05_secret-ownership.md`](2026-08-05_secret-ownership.md)).
