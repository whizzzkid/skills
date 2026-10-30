---
class: principle
---

# An environment failure blocks only the gates that need it

**Rule** — a broken test environment (registry auth, credentials, daemon, dependency install) stops only the
build/lint/test gates that depend on it. Keep implementing and committing; surface the blocker once with a fix CTA,
scoped to the gates it leaves unverified, and never report those gates as passed.

**Why** — under an unambiguous implementation directive, an install-time auth failure was treated as a plan-level
blocker: the agent stopped to ask and wrote no code, so the user had to ask why nothing was implemented. Editing needs
no credentials; only verification does. Consistent with the existing guardrails (prompt for re-auth, never retry in a
loop) — those govern the gate, not the edit.

**Where** — `SKILL.md` → Phase 3 execution-environment HARD RULE (new bullet); `README.md` Phase 3 summary.
