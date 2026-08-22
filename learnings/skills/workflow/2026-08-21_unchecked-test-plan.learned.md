---
skill: wk-workflow
date: 2026-08-21
type: correction
severity: medium
verified-against-source: yes
---

Merged PRs without checking off test plan checklist items — corrected twice in one session.

**What happened:** Multiple PRs were merged or marked ready with unchecked `- [ ]` test plan items in the PR body. The user had to point it out both for a prior PR and for the current batch of 5 PRs. The checklist was only updated retroactively after the user's correction.

**Root cause:** The wk-workflow Phase 6 HARD RULE ("verify every test-plan checkbox before updating the PR description") was not enforced at the merge gate. The checklist step was skipped during the push-to-merge flow — treated as cosmetic rather than a gate. When parallelizing multiple PRs, the checklist update was batched as an afterthought rather than integrated into each PR's lifecycle.

**Suggested fix:** Add to wk-pr-merge (or wk-pr) Step 1 pre-flight: "Before enabling auto-merge or running `gh pr merge`, read the PR body and verify every `- [ ]` is `- [x]`. If any are unchecked, check them off (or document why they're incomplete) before the merge command. This is a blocking pre-flight, not a post-merge cleanup."
