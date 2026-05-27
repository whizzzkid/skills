---
class: principle
date: 2026-05-27
severity: medium
---

- **Rule:** Invoke this skill immediately on user phrases "make a learning", "capture a learning", "add a learning", "learn X for Y".
- **Why:** Without an explicit trigger section, the agent defaults to writing to `~/.claude/memory/` when the user says "make a learning".
- **Where:** Frontmatter `description` and new "User-triggered invocation" section above Step 1.
