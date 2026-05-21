---
skill: wk-workflow
date: 2026-05-20
type: correction
severity: medium
---

Agent attempted Bash grep when user-provided GitHub URLs could be fetched directly via `gh` CLI.

**What happened:** User provided specific GitHub comment URLs as evidence of the bug. Agent ran a Bash grep instead of fetching the comment content from the API. User blocked the tool call and asked why the URLs weren't being accessed.

**Root cause:** When concrete GitHub artifacts (PR comment URLs, review comment URLs) are provided, the `gh api` CLI is the right first tool — not codebase grep. The wk-workflow "investigate user-provided artifacts first" rule applies here.

**Suggested fix:** When the user's message contains GitHub comment or review URLs, run `gh api repos/{owner}/{repo}/{pulls|issues}/comments/{id}` immediately before any codebase investigation. The response usually contains the exact text needed to diagnose the bug.
