---
skill: wk-gh
date: 2026-10-29
type: correction
severity: high
verified-against-source: yes
---

Agent reacted 👎 on bot review threads and answered in a top-level comment instead of replying in each thread.

**What happened:** Thread replies returned 422 "one pending review per pull request" because the user had an unsubmitted
review. Following the skill's fallback, the agent reacted on each thread and posted one issue comment covering all of
them. The user corrected this: a reaction with no in-thread explanation is useless to the reader, and thread replies
take priority.

**Root cause:** The skill's documented fallback (react plus one issue comment) routes around the blocker instead of
surfacing it. That puts the explanation off-thread, where neither reviewers nor the bot see it in context.

**Suggested fix:** Replace the fallback. On a reply 422 from a pending review, stop and ask the user to submit or
discard their draft (or approve adding the replies to it), then reply in every thread. Never react without a reply in
the same thread. An issue comment is for non-thread findings only. This supersedes the
already-distilled pending-review-blocks-replies learning, which introduced the bad fallback.
