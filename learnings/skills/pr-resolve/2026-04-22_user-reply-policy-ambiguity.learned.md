---
skill: wk:pr-resolve
date: 2026-04-22
type: gap
severity: medium
---

"Don't post the self-review" was ambiguous — user meant "don't post a formal PR Review, but do post individual reply comments".

**What happened:** At Step 7 confirmation, user replied "don't post the self-review". I interpreted this as "skip all reply posting" and began resolving threads without posting replies. User had to interrupt and clarify: "post the reply but not self-review". The term "self-review" in the user's vocabulary refers to the formal PR Review object (posted via `/reviews` endpoint, batched multi-comment review), which the skill does not produce anyway — it only posts threaded `/comments/{id}/replies`. But the skill flow lumps all author-posted text as "replies", making "don't post the self-review" hard to disambiguate from "don't post replies".

**Root cause:** The skill's Step 7 summary language ("I will push N commits, post M reply comments, resolve R threads") does not distinguish between (a) threaded replies to individual review comments and (b) an aggregate PR Review. Users familiar with GitHub's review-vs-reply distinction may use "self-review" to mean the latter, but the skill treats both as reply posting.

**Suggested fix:** In Step 7, explicitly label the replies as "threaded replies to individual review comments (not a formal PR Review)". If the user objects to "self-review" or "review", ask a clarifying question before interpreting — do not default to skipping all replies. Concretely: the skill should recognize "don't post the self-review" / "no review" as likely meaning "don't submit a PENDING review", and confirm before silencing threaded replies.
