---
class: principle
---

# Validate replacement prerequisites before cleanup

**Rule** — Preflight every replacement prerequisite, complete the replacement,
then remove deprecated active copies.

**Why** — Cleanup before either executable resolution or replacement success
turns an install failure into an empty active installation.

**Where** — `SKILL.md` Step 8 and the repository installer.

**Verification** — Behavioral tests prove missing and failing package runners
leave an existing active skill untouched.

**Byte arithmetic** — Body 24196 B + 133 B = 24329 B, below the 24576 B
ceiling; 380 B initial headroom exceeded twice the addition, so no reclaim was
owed. Audit cleanup measured 0 B in `SKILL.md`.
