---
class: principle
---

**Rule**

Never assert a result the agent cannot confirm in a drafted PR description. Gate
every Testing/Results section on known evidence (diff, CI output, user
statement). No evidence → write an honest placeholder (`Pending — <how to
exercise the change>`).

**Why**

Template-filling a complete description produces plausible-but-fabricated claims
like "build completed successfully" with no basis, shipping false evidence in the
PR body.

**Where**

`skills/pr-resolve/SKILL.md` → Step 8 (Sync PR description).
