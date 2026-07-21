---
skill: wk-pr-merge
date: 2026-07-21
type: gap
severity: medium
---

Post-merge state verification needs a standing `gh pr view` allow rule; compound commands defeat it.

**What happened:** After a successful `gh pr merge`, the Step 6 poll (`gh pr view --json state,mergeCommit`) was blocked by the auto-mode permission classifier, stalling the merge confirmation and Steps 7-10.

**Root cause:** Read-only `gh pr view`/`gh pr checks` were not in the allowlist. Adding `Bash(gh pr view:*)` fixed the bare call, but piping the output to `grep`/`jq` or joining with another command (e.g. `rm && gh pr view`) re-triggers the classifier — an allow rule matches only when the allowed command is the whole invocation.

**Suggested fix:** Recommend adding `Bash(gh pr view:*)` and `Bash(gh pr checks:*)` to allowed tools as a prerequisite; run these read-only calls as standalone invocations (no pipes/compound), doing any grep/jq filtering in a separate step, so the standing allow rule keeps matching.
