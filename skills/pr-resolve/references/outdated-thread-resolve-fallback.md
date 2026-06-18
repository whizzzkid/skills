---
class: principle
---

**Rule:** When a review thread is fully outdated (`line: null` in GraphQL), skip the REST reply entirely; resolve via GraphQL `resolveReviewThread` on the stable node ID and post one top-level `gh pr comment` summarizing the fixes in lieu of inline replies.

**Why:** Once `line` is `null`, every REST operation against the thread's `databaseId` 404s — reply POST, resolve PATCH, even the read GET. Only the GraphQL node ID stays valid.

**Where:** Step 8, reply/resolve bullets.
