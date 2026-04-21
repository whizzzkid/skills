---
skill: wk:pr-resolve
date: 2026-04-21
type: gap
severity: medium
---

Step 8 (Push and Respond) does not update the PR description after pushing review-iteration commits.

**What happened:** After pushing two review-fix commits during a pr-resolve session (absolute-URL fix and newline-separator fix), the PR description still said "10 tests" (now 13) and omitted both fixes. The user had to ask "is the PR description up to date?" to surface the drift. No automatic update happened.

**Root cause:** Step 8 only covers `git push`, sequential reply posting, and thread resolution. There is no instruction to run `gh pr edit` to sync the description with the current branch state. `wk:pr` has an explicit rule ("After EVERY push to a branch with an existing PR, the PR description MUST be updated"); `wk:pr-resolve` does not mirror it.

**Suggested fix:** Add to Step 8, after `git push`: "Update the PR description to reflect all commits pushed in this session — correct any counts, add mention of fixes applied, ensure the body matches the current branch state (`gh pr edit --body ...`)."
