---
skill: wk-pr-merge
date: 2026-11-20
type: correction
severity: high
verified-against-source: n/a
---

Claimed the post-merge retro was already captured, when only a pre-merge retro existed.

**What happened:** At Step 9 the agent said the retro was done, pointing to a retro file written before either merge.
The file left out every correction the user made after it was written. The user called the claim false.

**Root cause:** Step completion was judged by whether an artifact existed, not by whether it covered the events the
step is meant to capture.

**Suggested fix:** Step 9 always runs `wk-retro` after the merge. A retro written before the merge never satisfies it.
Before claiming any step is done, say which artifact and which events it covers.
