---
skill: wk-jira
date: 2026-10-30
type: correction
severity: medium
verified-against-source: n/a
---

An incident-driven fix with no ticket key should prompt ticket creation before the PR, not after.

**What happened:** An investigation turned into a fix and a PR with no ticket anywhere in context. Stage 1 found no
key, so the lifecycle was silently skipped. The user later had to ask for a ticket and noted the workflow required one.

**Root cause:** Stage 1's "no key → ask once" was never triggered, because the agent never ran Stage 1 when the task
pivoted from investigation to code change.

**Suggested fix:** When wk-workflow Phase 1 starts on a branch with no detected key, run Stage 1 and offer to create a
ticket (project, priority, sprint) before the first commit. Also note that a requested priority may not exist in the
project's scheme, so fall back to the highest allowed value and say so.
