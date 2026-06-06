---
skill: wk-goodmorning
date: 2026-05-28
type: gap
severity: medium
---

Standup sections must be top-level bullets with sub-bullets nested under them, not flat text.

**What happened:** The standup card rendered Yesterday/Today/Blockers as plain paragraph headings (`<p>` or `<b>`) with sub-items as sibling bullets — producing a flat list that lost the hierarchy when pasted into Slack.

**Root cause:** The skill describes the standup format using indented text with `-` prefixes but does not specify that the HTML implementation must use a nested `<ul><li>` structure where Yesterday/Today/Blockers are top-level `<li>` items containing child `<ul>` elements for their sub-points.

**Suggested fix:** Add an explicit structural rule to the standup HTML spec: "Yesterday, Today, and Blockers are top-level `<li>` items. All sub-points are nested `<ul><li>` children inside each. Never use flat headings or `<p>` tags — the nesting must be preserved so Slack's `text/html` clipboard paste renders correct indentation."
