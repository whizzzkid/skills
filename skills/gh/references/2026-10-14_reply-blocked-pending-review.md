---
class: principle
---

# Resolve a thread only after its reply lands

**Rule**

- Post the reply, check that it succeeded, and only then resolve the thread, as a separate step.

**Why**

- A REST `/replies` call returned 422 `user_id can only have one pending review per pull request` because the user had
  a staged self-review pending. The same chained command had already resolved the thread, so it sat resolved with no
  answer. The loud 422 is the intended guard (see `github-api-surfaces.md`), but the chained resolve ran anyway.

**Rejected suggestion**

- "Reply via GraphQL `addPullRequestReviewThreadReply` with the pending review's ID." That attaches the reply to the
  user's draft, so it stays hidden until the user submits. The installed guard exists to prevent exactly that, so this
  would relax it. The fallback stays the top-level comment from `pending-review-mechanics.md` → REST block.

**Where**

`skills/gh/SKILL.md` → Step 3; `skills/gh/references/github-api-surfaces.md` → pending-review reply guard.
