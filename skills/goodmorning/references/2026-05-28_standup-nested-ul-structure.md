---
class: principle
date: 2026-05-28
source: learnings/skills/goodmorning/2026-05-28_standup-nested-bullet-structure.md
severity: medium
---

- **Rule:** Render the standup HTML as a single top-level `<ul>` with Yesterday/Today/Blockers as `<li>` children, each containing a nested `<ul>` for sub-points; never use `<p>`/`<b>`/`<h*>` for the section labels.
- **Why:** Slack's `text/html` clipboard paste preserves indentation only when the source carries real `<ul>/<li>` hierarchy; flat headings collapse to one indent level on paste.
- **Where:** Standup snippet → HTML rendering (HARD RULE: Nested `<ul><li>` structure only).
