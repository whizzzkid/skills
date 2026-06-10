---
skill: wk-pr-resolve
date: 2026-06-09
type: gap
severity: medium
---

When round-over-round bot finding counts increase and new findings reverse previously-accepted fixes, declare terminal thrash and recommend merge — do not enter another fix cycle.

**What happened:** A PR went through 10 bot-review rounds. By round 8 counts were climbing (5 → 9), and by round 10 the bot was contradicting its own accepted findings (demanding mktemp one round, calling it over-engineered the next) and re-raising suggestions the author had explicitly rejected. Each fix round generated new reviewable surface, guaranteeing non-convergence.

**Root cause:** The existing thrash gate counts re-fires of one (path, concern_class) pair; it does not detect the broader pattern of rising totals plus accepted-fix reversals, which signals the review has exhausted real findings.

**Suggested fix:** Add a convergence check to Step 9.5: track total active findings per round. If count(N) >= count(N-1) for two consecutive rounds, or any new finding contradicts a previously-accepted fix in this session, present the merge-vs-continue decision to the user instead of re-entering the fix loop.
