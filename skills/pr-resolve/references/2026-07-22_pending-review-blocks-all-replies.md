---
class: principle
---

**Rule** — A pending self-review 422s reply-creation on **every** thread — bot and
reviewer included, not just the author's own. Route around it: post substance via
a single top-level `POST /issues/{n}/comments`, then resolve each worked thread
with the `resolveReviewThread` GraphQL mutation (not gated by the pending review).
Never submit or delete the pending review to unblock a reply (Hard Rule 13);
submit only on an explicit "submit my review".

**Why** — The REST reply endpoint implicitly creates a new pending review under the
same user and errors when one already exists. Thread resolution is a separate
mutation, unaffected by the pending review. Submitting to unblock publishes work
the human is holding for manual release.

**Where** — wk-pr-resolve Hard Rule 13, Step 3 gate; references/commands.md §3.
