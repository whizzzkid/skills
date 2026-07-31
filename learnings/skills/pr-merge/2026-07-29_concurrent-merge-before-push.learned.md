---
skill: wk-pr-merge
date: 2026-07-29
type: gap
severity: medium
verified-against-source: yes
---

Re-resolve pull request state before each post-fix push.

**What happened:** A pull request merged concurrently while another validated fix was being
prepared, and an interrupted push still advanced the merged head branch without changing the
already-created merge commit.

**Root cause:** The merge workflow resolves pull request state only at entry and does not re-check
it before a post-fix push or verify remote side effects after an interrupted command.

**Suggested fix:** Re-fetch pull request state immediately before every push or merge after a CI
repair cycle; if it is already merged, skip to post-merge processing, and after any interruption
verify the remote ref before retrying or reporting the command as cancelled.
