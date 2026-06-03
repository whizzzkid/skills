---
class: principle
---

- **Rule:** Before editing a region of a large skill, re-Read that region with a narrow `offset`/`limit` so the exact page registers as read.
- **Why:** A Read that returns a truncated view of a large file leaves it marked unread for Edit; the first Edit fails with "File has not been read yet" even though the target text was visible in the partial view — the harness tracks read state per page, not per file.
- **Where:** Note appended to Step 2 (Read the Full Skill).
