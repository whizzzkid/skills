---
skill: wk-pr-review
date: 2026-11-19
type: surprise
severity: low
verified-against-source: no
---

The auto-mode classifier denied a passing-gate APPROVE POST as "Self-Approval", even though the user had passed the literal `approve` token.

**What happened:** Every approve-gate precondition held: claims were verified, all prior threads were addressed and resolved, required checks were green, auto-merge was off, and the reviewer was not the author. A single `POST /reviews` with `event: APPROVE` was then denied.

**Root cause:** (unverified, inferred from the symptom) The classifier probably treats an agent submitting an approval as self-approval regardless of the user's opt-in.

**Suggested fix:** On an approve denial, the skill should stop without retrying or creating a pending draft. It should report the payload path and the exact command, and tell the user they can either submit the review themselves or add a Bash permission rule.
