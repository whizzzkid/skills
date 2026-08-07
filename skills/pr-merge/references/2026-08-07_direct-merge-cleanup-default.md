---
class: principle
---

# Direct workflow invocation owns its documented default

**Rule** — Treat direct invocation as authorization for the documented
delete-branch default. Offer an explicit keep-branch argument for exceptions.

**Why** — Prompting again for a default encoded in the invoked workflow makes a
deterministic operation appear indecisive.
