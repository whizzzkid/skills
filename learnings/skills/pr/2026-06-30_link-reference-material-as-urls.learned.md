---
skill: wk-pr
date: 2026-06-30
type: correction
severity: medium
---

"Link the reference material" during self-review means add source URLs to the PR description, not copy the referenced files into the repo.

**What happened:** Asked to "link the reference material" while preparing a self-review, the agent copied the referenced files into the repository instead of adding their source URLs to the PR description.

**Root cause:** "Link" was read as "make locally available" rather than "cite by URL". The skill did not force a scope check before creating files in response to a reference request.

**Suggested fix:** Treat "link the reference material" (and similar reference/citation requests) as a request to add source URLs to the PR description. Never copy referenced files into the repo to satisfy it. When a reference request is ambiguous about whether files should be created, clarify scope before creating any files.
