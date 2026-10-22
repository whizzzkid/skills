---
class: principle
---

**Rule** — Two delta-review hazards on a re-review:

1. **Rebased lineage.** When the last cleared SHA is not an ancestor of HEAD, map the last reviewed PR commit to its
   rebased copy (patch-id, subject fallback) and diff from that copy — never from the cleared SHA.
2. **Hostile quoted payloads.** Quote adversarial repro strings inside a code span or fence in every comment body,
   including the user's own drafts, so mentions, issue refs, and links stay inert.

**Why** — A two-dot diff from a pre-rebase SHA spans every base-branch change merged since, burying the small real
delta. A bare `@<team>` inside a quoted test payload notifies the whole team on post.

**Where** — Delta base: `wk-adversarial-review` `references/clearance-lineage.md` "Resolve the delta base".
Payload quoting: [`wk-pr-review`](../README.md) Phase 4.
