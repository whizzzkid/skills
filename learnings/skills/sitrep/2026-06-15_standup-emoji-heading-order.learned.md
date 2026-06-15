---
skill: wk-sitrep
date: 2026-06-15
type: correction
severity: medium
---

Standup snippet headings must lead with the emoji, not trail it.

**What happened:** The generated standup snippet placed day-marker emojis at the end of heading lines (`• Yesterday 👈🏽`) instead of at the start (`• 👈🏽 Yesterday`). The Blockers section was also missing its emoji entirely.

**Root cause:** The skill's standup formatting instruction delegates to wk-slack but does not specify emoji position within the heading line. The agent placed emojis as decorative suffixes rather than semantic prefixes.

**Suggested fix:** In the standup snippet format spec, add explicit examples showing the required heading format:
- `• 👈🏽 Yesterday` — emoji leads
- `• 👉🏽 Today` — emoji leads
- `• ✋🏽 Blockers` — emoji leads, always present (use `  • None` when empty)

Never place day-marker emojis at the end of a heading line.
