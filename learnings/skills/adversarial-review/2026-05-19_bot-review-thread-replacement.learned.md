---
skill: wk-adversarial-review
date: 2026-05-19
type: surprise
severity: medium
---

Bot review thread replacement collapses pre-push threads post-push.

**What happened:** Pre-push, a bot reviewer had 3 active inline threads on the
branch. After fixes were committed and pushed, the bot retracted all 3 threads
and posted a single new (outdated) thread re-raising one of the same concerns
before its database caught up with HEAD. Total thread count went from 3 to 1.

**Root cause:** Review bots that recreate their entire review object on each push
invalidate all pre-push REST comment IDs and reduce thread count. The new thread
replicates a concern already addressed, marked isOutdated, and classified as an
echo in wk-pr-resolve's "Re-surfaced findings" rule.

**Suggested fix:** When the pre-push comment map contains bot reviewers, the
adversarial review pre-flight should note the expected thread-collapse behavior
so the resolve skill isn't surprised by a smaller post-push thread count. Add a
note in the verdict that bot threads may consolidate on push and that a post-push
re-fetch is mandatory before posting replies.
