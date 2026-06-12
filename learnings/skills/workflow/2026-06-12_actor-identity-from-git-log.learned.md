---
skill: wk-workflow
date: 2026-06-12
type: correction
severity: medium
---

Use `git log` for author identity, not API construction

**What happened:** Initial implementation plan proposed constructing an RFC-2822 mailbox string from a GitHub API PR-author response. User corrected: use `git log -1 --pretty="%aN <%aE>"` directly from the commit history instead.

**Root cause:** When a spec says "pass the PR author identity to an external tool", the natural instinct is to fetch from the API (where PR metadata lives). But the commit history is the canonical source of author identity in a git-based pipeline — it reflects the actual commit author (mailmap-normalized), matches what the patch contains, and requires no API call.

**Suggested fix:** When adding actor/author identity forwarding to an external tool invocation in a CI script, default to reading from `git log --pretty="%aN <%aE>"` rather than constructing from API responses. Only fall back to the API if the commit history is unavailable or the required identity field is PR-opener rather than commit-author.
