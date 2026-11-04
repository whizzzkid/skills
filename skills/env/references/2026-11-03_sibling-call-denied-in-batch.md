---
class: principle
---

# A hook-rewritten call can sink its batch siblings

- **Rule:** A parallel call denied with `another call in this response was changed` → re-issue it alone in its own
  response. While a rewriting `PreToolUse` hook is registered, issue state-changing calls alone, never batched beside
  a Bash call.
- **Why:** During a sitrep rollover, a browser-close and a calendar read issued in the same response as other calls
  were each rejected with that text and succeeded only when re-issued alone. Mechanism unverified — inferred from the
  symptom: the hook rewrite changes one call's input, and the classifier then declines the whole batch.
- **Where:** [`wk-env`](../README.md) → Step 3.6, sibling-variant bullet.
