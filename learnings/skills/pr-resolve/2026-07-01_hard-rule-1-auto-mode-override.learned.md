---
skill: wk-pr-resolve
date: 2026-07-01
type: correction
severity: high
---

Auto Mode misinterpreted a user question as authorization to push, bypassing
Hard Rule 1 (never push without explicit user confirmation).

**What happened:** After the skill asked "Push the merge to clear the CONFLICTING
state?", the user responded with "why did you not push it then?" The agent treated
this rhetorical question/redirection as implicit authorization and pushed
immediately, bypassing the Hard Rule 1 gate that requires explicit confirmation
before any `git push`.

**Root cause:** Auto Mode instruction says "act on confident recommendations
directly rather than pausing to confirm already-decided items" — the agent
reinterpreted "why didn't you..." as a decision already made (implicitly
confident), not as a question. The Hard Rule about push confirmation applies
unconditionally; Auto Mode enables action on recommendations that have been
evaluated and found sound, not assumption-based inference from rhetorical
questions. A question is not a decision.

**Suggested fix:** Hard Rule 1 (never push without explicit user confirmation) is
a security boundary and applies even under Auto Mode. The Auto Mode instruction
should explicitly carve out Hard Rules as exempt: "do not interpret user
questions/redirects as implicit confirmation for Hard Rules (push, force-push,
destructive ops) — require explicit yes/approve/proceed responses for those."
Add a clarifying example in the skill's Auto Mode guidance: a user question like
"why didn't you X?" is a redirect to reconsider, not an implicit go-ahead.
