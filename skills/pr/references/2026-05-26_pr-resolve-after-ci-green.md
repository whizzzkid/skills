---
class: principle
date: 2026-05-26
source: learnings/skills/wk-pr/2026-05-26_run-pr-resolve-after-ci-green.md
---

- **Rule:** After CI goes green and before `gh pr ready`, invoke `wk-pr-resolve` to surface any description, self-review-thread, or reviewer-comment drift introduced during the CI wait. Sync per the no-ask drift rule.
- **Why:** Agent marked PR ready without checking for drift accumulated during the CI window; reviewers saw stale state.
- **Where:** Step 4 item 1 — new "Run `wk-pr-resolve` drift check" sub-step before description sync.
