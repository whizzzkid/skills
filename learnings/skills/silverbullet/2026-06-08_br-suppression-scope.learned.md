---
skill: wk-silverbullet
date: 2026-06-08
type: correction
severity: high
---

Use `.st-item + br { display: none }` not `.sitrep-col br { display: none }` — broad `<br>` suppression collapses meeting lines and `<pre>` content.

**What happened:** `.sitrep-col br { display: none }` hid ALL `<br>` elements inside the column, including line breaks between meeting entries and newlines within the standup `<pre>` block. Everything collapsed into one unreadable run-on block.

**Root cause:** SilverBullet inserts a `<br>` element for every newline in the HTML block source — including between plain-text meeting lines and inside `<pre>` tag content. A column-scoped `<br>` suppression rule hits all of these indiscriminately.

**Suggested fix:** Use the adjacent sibling selector to target only the `<br>` elements that follow `.st-item` spans (the inter-checklist-item gaps):
```css
.st-item + br { display: none; }
```
This leaves `<br>` elements between plain-text lines and inside `<pre>` blocks untouched.
