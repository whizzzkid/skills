---
skill: wk-pr-takeover
date: 2026-06-15
type: gap
severity: medium
---

Taking over a prose/docs-debloat PR: the orientation baseline is gate-preservation, not a test suite.

**What happened:** Took over a large PR that was almost entirely SKILL.md/markdown
compression (thousands of deleted lines across many skills, two skills removed).
Step 4's "run the test suite to establish a baseline" had nothing to run — the
repo's only executable gate is its pre-commit/pre-push hooks. The real takeover
risk was *silently dropped load-bearing rules* inside the compressed prose, which
no test catches. I validated by diffing each edited file against the base and
dispatching parallel reviewers to confirm each claimed gate survived.

**Root cause:** The skill assumes a code project with a runnable test suite. For
a docs/prompt/skill repo, "does it still pass" is the wrong baseline question; the
right one is "did the compression preserve every gate, link, and count."

**Suggested fix:** Add a branch to Step 4: when the diff is dominated by
documentation/prose/config rather than code, substitute a gate-preservation
audit — diff each touched file against the base, enumerate the rules/links/counts
the change claims to preserve, and verify each (parallel subagents scale well).
Run the repo's hooks as the executable baseline. Also note that takeover of one's
own PR makes the co-authorship trailer machinery a no-op — skip it when the sole
branch author is the user.
