---
class: principle
---

# Opt-in approval is a gated exception to pending-only posting

**Rule**

- `approve` token → submit the pending review as `APPROVE` only when the gate holds: zero `concern:` comments, no
  `blocked` verdict, no open prior own concern, no failing required check, reviewer is not the author.
- Gate miss → stay pending and report the reasons in the terminal. Never fall back to `COMMENT` or `REQUEST_CHANGES`.
- Only the literal token from the user in this task counts; dispatched callers never approve.

**Why**

- Pending-only posting forced a manual GitHub round-trip for clean PRs. Approval is irreversible and speaks for the
  user, so it needs explicit opt-in and a mechanical gate rather than judgment.
- Self-approval 422s on GitHub; checking authorship up front avoids a failed submit.

**Where** — `SKILL.md` → Approve Flag; Phase 5 first HARD RULE. Mechanics: `references/posting-pending-review.md` →
Submit as approval.
