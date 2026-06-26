---
skill: wk-plan
date: 2026-06-26
type: correction
severity: medium
---

Step 0 grill must ask ONE question per message and wait, never a batched list.

**What happened:** Step 0 instructs the agent to "ask the minimum set of questions
(max 4) via `AskUserQuestion`" — which renders a wall of simultaneous questions. The
user finds a batched/numbered list overwhelming and hard to answer cleanly, even when
each carries a recommended default.

**Root cause:** The rule optimized for fewest round-trips, not for the user's stated
preference. It also diverged from the analogous wk-pr-resolve rule, which already
mandates one comment at a time.

**Suggested fix:** Replace the "max 4 at once" guidance with: ask one question per
message, wait for the answer, then ask the next. Track answers as you go. Generalizes
the wk-pr-resolve one-comment-at-a-time rule to all clarifying/grilling/decision
flows.
