---
skill: wk-pr-review
date: 2026-06-16
type: correction
severity: medium
---

Always invoke wk-gh before posting any review body or inline comment.

**What happened:** Review comments and the review body were posted without the canonical outbound footer. The footer was omitted entirely rather than invented, but omission is still a violation of the skill's hard rule.

**Root cause:** `wk-gh` was never invoked during the review session. The footer text lives in `wk-gh` Step 4 and is not inlineable from memory — "do not invent one" means the skill load is mandatory, not that omission is acceptable.

**Suggested fix:** Add an explicit pre-flight step in Phase 4 (Review Comments): invoke `wk-gh` and extract the Step 4 footer before drafting any comment body. The footer must be appended to both the review body and every inline comment payload.
