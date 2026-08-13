---
class: principle
source: learnings/skills/silverbullet/2026-08-13_preescaped-inline-handler.md
date: 2026-08-13
skill: wk-silverbullet
---

## Principle

Write raw JavaScript operators (`&&`, `||`) in HTML onclick attributes; never pre-escape entities.
The renderer handles entity escaping. Pre-escaping causes double-encoding: `&&` becomes literal
`&amp;amp;&amp;amp;` in the DOM, the browser discards the handler.

Validate rendered handlers as executable DOM properties (`typeof el.onclick === 'function'`), not
source attribute strings (`getAttribute('onclick')`). The attribute string can look correct while
the browser has already rejected the handler due to entity corruption.

Reload a fresh page after source changes before validating. Exercise both success and failure
paths of async operations in handlers (e.g., clipboard write success + plain-text fallback).

## Folded Into

- `SKILL.md` — onclick attribute constraints: added `&` as third breaking character, raw-operator rule
- `SKILL.md` — Step 6 DOM inspection: `typeof el.onclick` replaces `getAttribute`
- `SKILL.md` — Step 6: added fresh-reload step and async-path exercise note
- `SKILL.md` — Common Mistakes: three new entries (pre-escaped `&&`, source-string-only validation, stale tab)
- `SKILL.md` — Quick Reference: handler entity row
