---
skill: wk-workflow
date: 2026-07-28
type: correction
severity: medium
verified-against-source: n/a
---

Respect an explicitly provided task branch as the implementation branch.

**What happened:** The workflow inferred that an item branch was required even though the user had
already placed the session on the correct dedicated branch, causing an unnecessary branch-creation
request.

**Root cause:** A repository planning convention was treated as stronger than the user's current
workspace choice.

**Suggested fix:** During branch pre-flight, treat the user's existing dedicated task branch as
authoritative. Create or propose another branch only when the current branch is default, detached,
dirty for unrelated work, or the user explicitly requests additional isolation.
