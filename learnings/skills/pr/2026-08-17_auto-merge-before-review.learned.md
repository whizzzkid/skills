---
skill: wk-pr
date: 2026-08-17
type: gap
severity: medium
verified-against-source: n/a
---

Auto-merge fast path enabled without adversarial review verdict

**What happened:** Agent enabled `gh pr merge --auto --squash` on a small-diff PR citing the trivial-PR fast-path clause (diff <25 lines). The clause's co-precondition — adversarial review has returned `clear` with zero findings — was not satisfied because `wk-adversarial-review` was never dispatched.

**Root cause:** The fast-path clause lists two co-preconditions (small diff AND clear review) but no mechanical gate enforces the review precondition. The agent can pattern-match on diff size alone and rationalize skipping the review.

**Suggested fix:** Add an explicit guard to the fast-path clause: before enabling auto-merge, verify that `wk-adversarial-review` was invoked in the current session and returned `clear`. If not invoked, dispatch it first — no size exemption. Consider requiring the review verdict as a variable the agent must cite (e.g., "adversarial review verdict: clear") rather than a prose precondition.
