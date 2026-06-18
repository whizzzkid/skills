---
skill: wk-adversarial-review
date: 2026-06-17
type: pattern
severity: high
---

Adversarial review surfaced a real git checkout abort (dirty tracked file blocks `git checkout -b branch origin/main`) and a false one (no-op on `git show` failure). Playground correctly distinguished them.

**What happened:** Two adversarial findings in the same session: (1) `git checkout -b new-branch origin/main` fails with "local changes would be overwritten" when a tracked file in the working tree differs from both HEAD and origin/main; (2) claim that `seed_state_from_remote` should write `{}` when `git show` fails, otherwise it is a bootstrap gap. Finding (1) was confirmed real via sandbox. Finding (2) was correctly downgraded to `question` — writing `{}` on `git show` failure would clobber legitimately local-only state; the no-op IS the correct bootstrap behavior.

**Root cause:** Both findings were about runtime behavior. Playground validation correctly separated the real failure mode (checkout abort with dirty file) from the fabricated one (seed-state no-op). Without playground, the fabricated blocker could have shipped a data-loss fix.

**Suggested fix:** When adversarial review produces two conflicting severity claims in the same diff area, require independent playground tests for *each* before accepting either. A finding that "safe no-op is broken" needs a concrete failure scenario to be a blocker; if the no-op is correct for the bootstrap case, "write empty state" is the wrong fix. Add an explicit note to the skill: adversarial claims about missing error-path writes must include a concrete failure scenario where the absence causes incorrect behavior, not just absence of defensive code.
