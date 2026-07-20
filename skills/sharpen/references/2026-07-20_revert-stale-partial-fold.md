---
class: principle
---

**Rule** — During the Step 5 audit, treat any uncommitted edit to the target
`SKILL.md` not made this run as suspect. Verify each against the distilled lesson;
revert those that don't address the root cause instead of committing them alongside
the real fix.

**Why** — A prior session's partial fold left in the working tree can encode the
wrong mental model. Building on it ships the misconception. wk-sharpen reads the full
skill but had no explicit step to distrust pre-existing uncommitted changes.

**Where** — `skills/sharpen/SKILL.md` Step 5 (Audit the Full Skill), "Remove dead
labels" bullet.
