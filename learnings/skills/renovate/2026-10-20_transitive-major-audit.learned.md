---
skill: wk-renovate
date: 2026-10-20
type: gap
severity: high
verified-against-source: yes
---

A grouped patch bump pulled in a transitive major (json 2.x → 3.x) that broke an error path no test covered.

**What happened:** The suite was green; only an adversarial review reading the gem source found the regression (generator raises on binary strings).

**Root cause:** The skill lists only direct bumps and treats green tests as sufficient.

**Suggested fix:** In Step 1, diff the lockfile for transitive major bumps and flag them; in Step 4, require a changelog/breaking-change audit of each against app usage, and never skip adversarial review when one exists.
