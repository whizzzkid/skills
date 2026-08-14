---
class: principle
severity: medium
source: learnings/skills/gh/2026-08-14_use-reactions-api-not-emoji-text.md
---

## Use GitHub reactions API, not emoji characters in reply text

Agent embedded emoji characters (thumbs-up/down) in reply comment text instead
of using GitHub's native reactions API endpoint. "React with thumbs-up" is an
API action (`POST repos/{owner}/{repo}/pulls/comments/{id}/reactions`), not a
text-formatting instruction.

**Landed in:** `SKILL.md` Step 4 → "Use the reactions API, not emoji text" block.
