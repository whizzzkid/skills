---
skill: wk-buildkite
date: 2026-06-11
type: correction
severity: medium
source: memory:feedback_only_own_prs
---

Only investigate CI failures and make changes on PRs whose branch the agent
created in the current engagement.

**What happened:** Agent started debugging a PR it did not create and had no
context on, after the user mentioned it was failing.

**Root cause:** No branch/author gate before CI investigation; "PR #N is
failing" was treated as authorization.

**Distilled:** wk-buildkite "HARD RULE: investigate only your own branches" —
check `gh pr view --json headRefName,author`; stop on an unfamiliar branch.
