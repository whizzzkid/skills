---
class: principle
---

**Rule** — Before any readiness/mergeable claim after a bot re-review, fetch the PR's `mergeStateStatus`/`reviewDecision` directly (source of truth) and grep the latest bot issue-comment/review body for severity markers ("Major", "blocker"). Never infer mergeability from CI status or inline-thread count alone.

**Why** — A bot's re-review posted two new Major findings only in its top-level summary comment (`issues/comments`), with no inline `reviewThreads` entry; `mergeStateStatus` was `BLOCKED`. The gate treated "no new inline threads" + green CI as "ready" and shipped a false "mergeable" claim, caught only by user pushback.

**Where** — `wk-adversarial-review` sweep 2.64 (extended catalog).
