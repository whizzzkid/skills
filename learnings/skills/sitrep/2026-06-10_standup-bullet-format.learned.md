---
skill: wk-sitrep
date: 2026-06-10
type: correction
severity: medium
---

Standup snippet day markers must be top-level bullets with indented sub-bullets, not bare labels followed by `·`-joined items on one line.

**What happened:** The standup `<pre>` block rendered day markers (`👈🏽 Yesterday`, `👉🏽 Today`, `✋🏽 Blockers`) as bare labels with all items concatenated on a single line using `·` as a separator.

**Root cause:** The skill spec shows one line per section (`👈🏽 Yesterday: {achievement} {url}`) which was interpreted as a single-line format. The spec doesn't explicitly require bullet hierarchy for multi-item sections.

**Suggested fix:** Update the standup snippet format in the skill to require bullet hierarchy when a section has multiple items:

```
• 👈🏽 Yesterday:
  • {achievement} {url}
  • {achievement} {url}
• 👉🏽 Today:
  • {priority} {url}
• ✋🏽 Blockers:
  • {blocker} {url}
```

Day markers are always top-level `•` bullets. Each achievement/priority/blocker is always an indented `  •` sub-bullet on its own line. Never join multiple items with `·` on a single line.
