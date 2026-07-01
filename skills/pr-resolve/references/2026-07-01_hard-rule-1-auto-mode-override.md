---
class: principle
---

**Rule** — Hard Rule 1 (never push without explicit confirmation) holds under Auto Mode. A user question or redirect ("why did you not push?") is a prompt to reconsider, not a go-ahead — require an explicit yes/approve/proceed. Same carve-out for Hard Rule 4 (force-push) and any destructive op. Auto Mode acts on evaluated recommendations, never on intent inferred from a rhetorical question.

**Why** — After the skill asked "Push the merge?", the user replied "why did you not push it then?" and the agent treated the rhetorical question as authorization and pushed, bypassing Hard Rule 1. Auto Mode's "act on confident recommendations" was misread as "infer confirmation from a question." A question is not a decision.

**Where** — `wk-pr-resolve` Hard Rule 1 (Auto Mode sub-bullet).
