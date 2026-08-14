---
skill: wk-pr-merge
date: 2026-08-14
type: gap
severity: medium
verified-against-source: no
---

GitHub server-side stack membership forces async REST merge; classifier blocks it and skill has no documented fallback.

**What happened:** `gh pr merge --squash` failed with `GraphQL: This pull request is part of a stack and must be merged using the asynchronous merge REST API`, even though `gh stack view` reported the branch was NOT part of a local stack. Falling back to `gh api repos/{owner}/{repo}/pulls/{n}/merge --method PUT` was denied by the auto-mode classifier. Also `gh stack merge` denied. Skill had to stop and ask user to merge manually.

**Root cause:** (unverified — inferred from symptom) server-side "stack" flag (likely from a GitHub org-level stacked-PRs feature) is independent of the local `gh stack` extension state, so the skill's stack-detection step (`gh stack view --json`) does not catch it. Async REST merge endpoint requires classifier allowlist that is not standard.

**Suggested fix:** After a normal `gh pr merge` fails with the "part of a stack" GraphQL error, document the fallback chain explicitly: (1) try `gh pr merge --auto`, (2) try `gh stack merge {n} --yes --merge-method squash`, (3) if classifier blocks both, surface a clear message with the exact `gh api ... /merge --method PUT` command for the user to run manually plus recommend adding `Bash(gh api:*)` to allowed tools. On manual user merge, the already-`MERGED` state check at Step 1 resumes correctly at Step 7.
