---
class: principle
---

**Rule**

Read bot inline-comment bodies via GraphQL `reviewThreads` →
`comments.nodes[0].body`, not REST `GET /pulls/{n}/comments/{id}`.

**Why**

After a bot replaces its review object, the REST `databaseId` is invalid for
*all* operations — even a read GET returns 404, not just reply/resolve writes.
The thread node ID is stable across pushes.

**Where**

`skills/pr-resolve/SKILL.md` → Step 3 (Fetch Unresolved Comments).
