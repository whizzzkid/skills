---
skill: wk-pr
date: 2026-06-25
type: correction
severity: high
---

Did not invoke wk-pr after pushing to a new branch with no open PR.

**What happened:** After committing and pushing to a new branch, the agent stopped without creating a PR. wk-workflow Phase 5 is a HARD RULE: every push to a branch with no open PR invokes wk-pr automatically. The user had to point this out.

**Root cause:** The workflow was not followed end-to-end after the push. The agent treated "pushed successfully" as the terminus rather than continuing to the PR creation phase.

**Suggested fix:** After every successful git push, immediately check for an open PR (`gh pr view 2>/dev/null`). If none exists, invoke wk-pr without waiting for the user to ask. "Push succeeded" is not "work complete" — wk-pr is the mandatory next step.
