---
class: principle
date: 2026-05-28
source: learnings/skills/slack/2026-05-28_standup-snippet-structure.md
severity: high
---

- **Rule:** wk-slack owns the canonical Standup Snippet spec — nested `<ul><li>`, one link per leaf bullet, `repo#number` labels, `ClipboardItem` `text/html` copy, mandatory section emoji, omit Blockers when empty.
- **Why:** Repeated structure/format mistakes (flat bullets, multiple links per line, bare `#NNN`, plain-text-only clipboard) came from callers reinventing the spec; centralizing in wk-slack lets daily sitrep callers delegate.
- **Where:** New `## Standup Snippet` section in wk-slack (structure block + privacy filter + caller contract).
