---
skill: wk-pr
date: 2026-07-28
type: gap
severity: medium
verified-against-source: n/a
---

Hard Rule 2's "review before every push" is what multiplies review runs across a fix loop, and the rule offers no batching guidance.

**What happened:** A feature branch went through several rounds of blocker fixes, each ending in a push. Rule 2 was read literally, so the adversarial review ran again each time; {user} interrupted and waived the gate outright out of fatigue.

**Root cause:** Rule 2 enumerates the transitions that require a review (first push, every subsequent push, ready, force-push) without distinguishing a *fix-loop* push — a push whose only purpose is to land review findings already surfaced — from a push that introduces new, unreviewed work. So the loop's own remediation pushes each re-trigger the gate.

**Suggested fix:** Amend Rule 2 to require a review before the PR-creating push and before `gh pr ready`, and to collapse all fix-loop pushes in between into a single scoped re-review of the diff since the last verdict. Add that a user's explicit waiver or fatigue signal ends the gate for the session and must be honored without re-litigation.
