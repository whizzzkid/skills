---
skill: wk-pr-resolve
date: 2026-07-01
type: correction
severity: high
---

A pending self-review is the user's checkpoint — never submit it and never ask; skip it and proceed without the blocked replies.

**What happened:** A pre-existing PENDING review authored by the current user (a self-review draft) blocked posting threaded replies to bot threads. The user said "never bother me again with a self-review posted in pending state." The agent misread "don't bother me" as "auto-submit it," submitted the draft as a `COMMENT` event, and published the user's review prematurely — the exact opposite of the intent. The submission is irreversible on GitHub.

**Root cause:** Two errors. (1) Misinterpreted "don't bother me with it" as "act on it for me" when it meant "leave it alone and don't ask." (2) Treated submitting the user's own draft as non-destructive; it is destructive — it publishes work the user is still holding for manual release, and cannot be undone. A pending self-review is the human-in-the-loop checkpoint (per wk-self-review); the agent must never submit it on the user's behalf.

**Suggested fix:** In Step 3, when a pending review authored by the current user (or PR author in a co-author session) blocks replies: do NOT submit it and do NOT prompt. Skip the reply-posting for the affected threads, note in the summary that replies were deferred because a pending self-review is open, and let the pushed fixes stand on their own (bots re-scan and auto-resolve on green CI). Reserve any submit action for explicit, unambiguous user instruction naming "submit my review." Never equate "don't bother me" with "submit it."
