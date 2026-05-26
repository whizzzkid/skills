---
skill: wk-pr-review
date: 2026-05-26
type: surprise
severity: low
---

Pending review inline comments show `line: null` when fetched via the API before submission.

**What happened:** After posting a pending review with inline comments, a verification fetch of `/pulls/{n}/reviews/{id}/comments` returned `line: null` and `start_line: null` for both entries — even though the comments were anchored to specific lines in the payload. The review body was present and correct.

**Root cause:** GitHub's REST API does not surface line/position metadata for comments that belong to a PENDING (draft) review. The fields are only populated once the review is submitted. This is expected API behavior, not a payload error.

**Suggested fix:** When verifying pending review comments, check `path` and `body` prefix rather than `line` — those fields are populated even for draft state. Note in the skill's "After posting" section that line fields will be null for pending reviews; don't use them as a success signal.
