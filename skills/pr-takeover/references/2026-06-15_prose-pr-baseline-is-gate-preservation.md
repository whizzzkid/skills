---
class: principle
date: 2026-06-15
---

# Prose-dominated takeovers use a gate-preservation baseline, not a test suite

**Rule:** When a taken-over PR's diff is dominated by documentation / prose /
config rather than code, substitute a gate-preservation audit for Step 4's
test-suite baseline: run the repo's hooks as the executable baseline, diff each
touched file against the base, and verify every rule, link, and count the change
claims to preserve still survives. Skip the co-authorship trailer when the sole
branch author is the user.

**Why:** The skill assumes a code project with a runnable suite; a docs/skill repo
often has none, and "does it still pass" is the wrong question. The real risk is a
silently dropped load-bearing rule inside compressed prose, which no test catches.
Own-PR takeover makes the co-author machinery a no-op.

**Where:** Step 4 (prose-diff branch) and Step 5 (own-PR skip).
