---
skill: wk-pr-resolve
date: 2026-05-19
type: surprise
severity: low
---

Bot summary issue comments update in-place after fixes land, not by posting a new comment.

**What happened:** After fixes were pushed, the bot rewrote its existing issue comment from "Found N issues" to "No issues found" rather than posting a second comment. The post-CI re-fetch showed no new active findings, which was correct, but the in-place edit is invisible to the diff-based "new comment" detection.

**Root cause:** Bots that track PR state often use a single persistent issue comment (identified by a magic HTML comment marker like `<!-- {repo}-review -->`) and overwrite it on each review cycle. This is distinct from inline review threads, which are replaced by posting new threads.

**Suggested fix:** When checking for new post-CI issue comments, also check whether any existing bot issue comment's body changed since the pre-push snapshot. A body change from "Found N issues" to "No issues found" is a positive signal — the bot considers everything resolved — and should be noted in the session summary.
