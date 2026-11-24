---
skill: wk-sitrep
date: 2026-11-24
type: gap
severity: medium
verified-against-source: n/a
---

Generated item text containing a raw `<word>` placeholder nested every column inside the first; only the render gate caught it.

**What happened:** A new item quoted a naming pattern with an angle-bracketed placeholder inside a column span. The page committed-to-disk looked fine, but the rendered page collapsed to one column with two nested columns. Replacing the angle brackets with braces restored three columns.

**Root cause:** The skill bans HTML entities and raw `<br>` lines in column text but does not say that any literal `<` or `>` in item text (placeholders, generics, comparison operators) is parsed as an HTML tag inside the column block. A generator that only escapes `#` lets it through.

**Suggested fix:** In the rendering contract and the inline generator recipe, require stripping or replacing every `<` and `>` in item text with a plain glyph (braces, a dash) before writing, and add a pre-write assertion that no span text contains `<` outside the canonical markup. Keep the render gate as the backstop. Also note that review subagents launched from an unattended shell may lack an SSH key, so the auto-review stage should probe `git ls-remote` on the clone first and report the skip up front.
