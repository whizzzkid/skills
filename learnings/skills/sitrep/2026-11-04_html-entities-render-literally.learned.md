---
skill: wk-sitrep
date: 2026-11-04
type: gap
severity: low
verified-against-source: yes
---

HTML entities such as `&lt;` and `&gt;` in info spans render as literal text on the live page.

**What happened:** The generated page wrote a meeting title containing angle brackets as `&lt;&gt;` inside
`st-item st-info` spans. The render-verify screenshot showed the literal entity text instead of the characters.
Replacing the entity pair with a plain separator glyph fixed it, and a body-text check confirmed no literal `&lt;`
remained.

**Root cause:** The span content is processed as page markup, not raw HTML text, so entities are not decoded there.
Verified by loading the page in the browser and reading the rendered text. The contract has no rule on characters that
need escaping in span text.

**Suggested fix:** Add a rule to the rendering contract: never emit HTML entities in span text. Replace angle brackets
in titles with a plain separator, and add a body-text check for literal `&lt;` or `&amp;` to the Stage 5 render gate.
