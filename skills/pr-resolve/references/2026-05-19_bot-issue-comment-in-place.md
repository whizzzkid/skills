---
class: principle
date: 2026-05-19
---

- **Rule:** Re-fetch each bot-authored issue comment captured pre-push
  and compare its body against the snapshot; transitions to a clean
  shape are a positive resolution signal, transitions to new findings
  are a regression.
- **Why:** Some bots key on a magic HTML marker and overwrite a single
  persistent issue comment rather than posting new ones; diff-based
  "new comment" detection misses the update.
- **Where:** Step 8 "Detect in-place updates to bot summary issue
  comments".
