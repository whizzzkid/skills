---
skill: wk-adversarial-review
date: 2026-06-09
type: gap
severity: medium
---

Warn the user explicitly when a fallback produces a value that must match remote state they may have forgotten to push.

**What happened:** SHA-fallback instruction said to "warn the user" but only as a parenthetical note — the warning was likely to be omitted or buried. Fresh Eyes flagged it as "a Claude following these instructions is likely to omit the warning."

**Root cause:** Prose notes in skill instructions ("note: warn the user") are softer than explicit imperative instructions ("output a visible warning block"). Sweep 2.4 (comment accuracy) could catch this by checking whether "warn" claims are backed by an explicit instruction.

**Suggested fix:** Add to 2.4: when a skill instruction uses the phrase "warn the user" without a corresponding explicit output block, flag it as potentially ineffective.
