---
class: principle
---

# Validate processed archive formatting

**Rule** — validate each processed-state archive against its active format rules before staging, and fix failures in
the same archive commit.

**Why** — a rename can publish inherited format violations even when filename, scope, policy, and signature gates
pass.

**Where** — `SKILL.md` → Step 8 → Commit.
