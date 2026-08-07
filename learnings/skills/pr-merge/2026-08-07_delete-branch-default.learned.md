---
skill: wk-pr-merge
date: 2026-08-07
type: correction
severity: medium
verified-against-source: yes
---

Make branch cleanup deterministic for direct merge-workflow invocations.

**What happened:** The workflow paused for branch-deletion confirmation even though its documented merge command already includes branch deletion, and the user expected the invoked workflow to run without an extra preference question.

**Root cause:** The skill simultaneously defines branch deletion as the normal merge command and requires a confirmation whenever repository-level automatic deletion is disabled. Reading and executing both instructions produced a redundant prompt.

**Suggested fix:** Define direct invocation as authorization for the documented delete-branch default, add an explicit keep-branch argument for exceptions, and reserve confirmation for natural-language merge requests whose cleanup preference is genuinely unknown.
