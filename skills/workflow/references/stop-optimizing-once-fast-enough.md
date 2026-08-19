---
class: principle
---

**Rule** — After the primary goal is met, a clarifying question ("why is X slow?") seeks understanding, not more work. Answer and stop; do not pair with a new optimization proposal unless the user explicitly asks.

**Why** — No stopping criterion for "good enough" performance work caused the agent to treat every follow-up timing question as an invitation to propose another optimization, even after the target metric had already improved dramatically.

**Where** — `SKILL.md` → Autonomy Rules → "Curiosity ≠ commission" bullet.
