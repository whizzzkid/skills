---
class: principle
source: learnings/skills/pr-resolve/2026-08-27_dont-fight-the-review-bot.md
---

# Reproduction applies to dismissals, not just fixes

**Rule:** Before dismissing any bot/scanner Major finding, attempt reproduction
with the same rigor as a fix. Arguing "false positive" without evidence is a
violation of the reproduction rule — the finding is a hypothesis to test, not
adversarial noise to refute.

**Why:** Agent argued two Major bot findings out of scope without reproducing.
After implementing the fixes instead, CI passed and the bot approved — the
defects were real. The reproduction rule said "before fixing"; the agent read
that as not covering dismissals.

**Where:** Step 4, reproduction bullet — widened from "before fixing" to "before
acting on it (fix OR dismiss)."
