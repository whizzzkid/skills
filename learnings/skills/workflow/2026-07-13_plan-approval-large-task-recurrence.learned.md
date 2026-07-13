---
skill: wk-workflow
date: 2026-07-13
type: correction
severity: high
---

Executed before plan approval again — this time rationalized by task size being large/exciting, not small.

**What happened:** On a large, open-ended creative build (a multi-slide interactive artifact), the agent began fetching reference material and writing the foundation file before the user approved the plan. The user interrupted with "why did you not wait for me to approve the plan?" and then supplied several plan revisions — confirming the plan was not yet final, let alone approved.

**Root cause:** The plan-approval gate is already distilled (see `2026-06-25_skip-plan-approval`), but that fix framed the failure as "small-task rationalization." A large, engaging task triggers the *opposite* rationalization — momentum/excitement ("the direction is obviously right, let me get building") — and slips past the same gate. The distilled rule's "even 2-line changes" framing does not visibly cover the large-task case, so it did not steer.

**Suggested fix:** State the gate as size-independent in BOTH directions: neither "too small to plan" nor "too big/clear to wait" waives it. The first Edit/Write/Bash write-action — including reading/fetching *for* the build, if it commits to a direction — waits for explicit plan approval. Momentum on an exciting task is a rationalization to name explicitly alongside "small task."
