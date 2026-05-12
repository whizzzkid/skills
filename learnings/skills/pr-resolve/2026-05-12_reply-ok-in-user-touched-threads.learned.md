---
skill: wk-pr-resolve
date: 2026-05-12
type: correction
severity: medium
---

The agent CAN post follow-up comments in threads where the current user has already replied, if the finding changed or a new item needs explicit callout.

**What happened:** During a co-author resolve session, the agent was writing a memory entry treating all non-self threads as off-limits for follow-up. The user interrupted and corrected: "you can also touch thread I responded to, but only if the findings changed or there's a new item that needs to be explicitly called out."

**Root cause:** The thread exclusion rule ("never touch other reviewers' or bot threads") was applied too broadly. The user's prior reply to a thread signals engagement and grants permission for targeted follow-up — the rule was meant to prevent unsolicited new comments on threads the user hasn't touched.

**Suggested fix:** Refine the thread-touching rule:
- **Off-limits (never add comments):** Bot or reviewer threads where the current user has NOT posted any reply.
- **Eligible for follow-up:** Threads where the current user HAS already replied — agent may add a follow-up comment IF: (a) the finding was updated by a new fix in this session, OR (b) there is a new item not covered by the user's existing reply that needs explicit callout.
- **Still never resolve:** Don't mark threads as resolved unless the agent directly worked the fix. Posting a follow-up comment does not grant resolution rights.
