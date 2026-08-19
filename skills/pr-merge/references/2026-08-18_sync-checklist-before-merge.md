---
class: principle
---

**Rule** — Before the Step 5 unchecked-item gate, sync the PR body to reflect
items the current session has already verified. A verified-but-unchecked item
blocks the merge gate unnecessarily.

**Why** — The agent treated verification and description-sync as independent
steps. Verification results were not written back to the PR body, so the
unchecked-item scan flagged items the session had already confirmed — requiring
the user to remind the agent to check them off.

**Where** — `SKILL.md` → Step 5 → *Sync verified test-plan items before
scanning* (new sub-step).
