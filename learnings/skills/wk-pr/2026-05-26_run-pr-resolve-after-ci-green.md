---
skill: wk-pr
date: 2026-05-26
type: gap
severity: medium
---

After CI passes, run wk-pr-resolve to ensure description and self-review comments haven't drifted.

**What happened:** Agent marked PR ready without checking whether the description or self-review threads had drifted since the last push.

**Root cause:** No explicit post-CI-green drift-check step in the wk-pr flow.

**Suggested fix:** After the CI-green exit and before `gh pr ready`, invoke wk-pr-resolve to surface and resolve any comment or description drift introduced during the CI wait window.
