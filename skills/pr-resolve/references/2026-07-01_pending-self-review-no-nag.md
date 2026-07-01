---
class: principle
---

**Rule** — The author's own pending self-review is theirs alone. Detect it once at Step 3, state the reply-endpoint consequence, and route around it via the no-body GraphQL resolve path. Never demand submission and never re-prompt to submit — not as a precondition to fixing reviewer/bot findings. Re-prompting more than once per session is a violation.

**Why** — A pending self-review by the PR author blocked reply posting (HTTP 422). The skill pushed the author to submit-or-abort, then re-raised it on later reply attempts. The author pushed back: the self-review is theirs to submit whenever they choose. Reply-blocking was already worked around correctly by resolving threads via GraphQL (no body, not gated by the pending review); the repeated nagging should never have happened.

**Where** — `wk-pr-resolve` Hard Rule 13 + Step 3 pending-review pre-check.
