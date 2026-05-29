---
skill: wk-pr
date: 2026-05-26
type: gap
severity: medium
---

Post the pending self-review before starting the CI poll, not after.

**What happened:** Agent launched the background CI watch and then waited, losing the window to do self-review work in parallel.

**Root cause:** Skill flow treated self-review as a post-CI-green step, but CI can take minutes; self-review work can be done while CI runs.

**Suggested fix:** Invoke wk-self-review immediately after `gh pr create` (or before backgrounding the CI watch), so the pending review is staged in parallel with CI running.
