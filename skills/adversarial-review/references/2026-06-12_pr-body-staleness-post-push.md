---
class: principle
date: 2026-06-12
skill: wk-adversarial-review
---

- **Rule:** Record 2.10 PR-body staleness findings as post-push TODOs, not
  push-gating blockers. Sequence: push → update body to new HEAD → re-fetch
  surfaces. The finding still blocks marking ready, not the push.
- **Why:** The body describes what is live in the PR; commits aren't live
  until pushed, so updating the body pre-push inverts the causal order.
- **Where:** Step 2 sweep 2.10 PR metadata sync — added the post-push note.
