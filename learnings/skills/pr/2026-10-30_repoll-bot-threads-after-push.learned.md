---
skill: wk-pr
date: 2026-10-30
type: correction
severity: high
verified-against-source: n/a
---

Green CI plus a "review required" merge state is not done; re-poll review threads after every push.

**What happened:** After pushing review fixes, the agent reported the PR as needing only human approval, based on
`statusCheckRollup` and `reviewDecision`. A review bot had posted a blocker and a major on the new head; the user had
to point them out.

**Root cause:** The agent checked CI and merge state, but not unresolved review threads, before reporting status. The
bot's top-level review body was empty, which hid the findings unless threads were queried.

**Suggested fix:** Before any status report after a push, query unresolved `reviewThreads` (GraphQL) and wait for bot
reviewers to post on the current head SHA. Treat any unresolved blocker or major as open work, not "awaiting approval".
