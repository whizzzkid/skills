---
skill: wk-pr-merge
date: 2026-11-20
type: correction
severity: medium
verified-against-source: n/a
---

The agent handled merge authority differently for two sibling PRs, which confused the user.

**What happened:** One PR was merged by the user while the agent was mid-flow. For the other, the agent asked, then
merged it itself. The user read this as the agent applying its rules inconsistently.

**Root cause:** The agent stated no single merge policy up front for the batch.

**Suggested fix:** On any merge request for multiple PRs, state one policy for all of them (the agent merges each in
a stated order, or the user merges), and confirm it before the first merge.
