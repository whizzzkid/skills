---
skill: wk-adversarial-review
date: 2026-05-19
type: pattern
severity: medium
---

Post-push bot re-review replaces ALL prior threads; every finding appears as new even when addressed.

**What happened:** After push, the review bot created entirely new thread IDs covering the same findings the prior cycle addressed. The post-push graphql fetch showed 7 "new" bot threads — all echoes of already-fixed issues. The bot's re-review was based on stale diff context from before the push.

**Root cause:** Review bots that recreate their entire review object on each push destroy prior REST comment IDs. The bot re-evaluates the diff but its database hasn't caught up with HEAD, so it re-reports findings from the pre-push state. This is documented in Step 8 of the skill but easy to miss under time pressure.

**Suggested fix:** Before entering the Step 9.5 loop, pre-build a `session_resolved_classes` set: `{(path_prefix, concern_class)}` for every finding addressed in this session. In Step 9.5's thread comparison, match new bot threads against this set by concern class first (before matching by exact path:line), tag as `already-addressed` early, and skip triage. This prevents re-entering Step 4 for the whole echo batch.
