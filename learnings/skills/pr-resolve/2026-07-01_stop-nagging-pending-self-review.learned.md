---
skill: wk-pr-resolve
date: 2026-07-01
type: correction
severity: medium
---

Once a pending self-review is detected, note it once and route around it silently — never repeatedly prompt the author to submit their own review.

**What happened:** A pending self-review by the PR author blocked reply posting (HTTP 422). The skill surfaced this and pushed the author to submit or abort — then re-raised it on later reply attempts. The author pushed back sharply: the self-review is theirs to submit whenever they choose; the agent should stop asking and just fix the findings. Reply-blocking was worked around correctly by resolving threads via GraphQL (no body, not gated by the pending review), but the repeated nagging should never have happened.

**Root cause:** Step 3's pending-review pre-check treats "author must submit or abort" as the only resolution, and reply-time fallback logic re-triggers the prompt. The skill has no "author declined once, do not re-ask this session" latch, and conflates 'blocks reply' with 'must be submitted'.

**Suggested fix:** In Step 3, when a pending self-review is the author's own, detect it once, state the reply-endpoint consequence, and default to the no-reply / resolve-via-GraphQL path without demanding submission. Add a hard rule: the author's pending self-review is theirs alone — never prompt to submit it more than once per session, and never as a precondition to fixing reviewer/bot findings. Treat re-prompting as a violation.
