---
skill: wk:pr-resolve
date: 2026-04-24
type: gap
severity: high
---

Bot review replacement invalidates REST comment IDs — use GraphQL thread node IDs instead.

**What happened:** `{bot}` replaces its entire review object on every push. REST replies via `POST /pulls/{n}/comments/{id}/replies` returned 404 (`Parent comment not found`). Switched to GraphQL `resolveReviewThread` mutation with `PRRT_...` node IDs, which survive replacement.

**Root cause:** Skill has no guidance on this bot behavior; it assumes REST comment IDs are stable.

**Suggested fix:** Add a note in the bot review handling section: when REST replies fail 404, use GraphQL `resolveReviewThread` by thread node ID. Mention that bots replacing full reviews is the most common cause.
