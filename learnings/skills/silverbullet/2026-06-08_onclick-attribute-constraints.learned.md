---
skill: wk-silverbullet
date: 2026-06-08
type: correction
severity: medium
---

Two constraints apply to JavaScript in inline `onclick` attribute values: no `>` (arrow functions) and no `"` (attribute delimiter conflict).

**What happened:** An `onchange` handler using `=>` arrow functions was truncated in the rendered DOM at the `>` character. A handler using `"` inside a double-quoted attribute value broke attribute parsing.

**Root cause:** SilverBullet's HTML parser interprets `>` as a tag-close character even inside attribute values in some parsing paths. Double-quotes `"` inside a `"..."` attribute value always terminates the attribute.

**Suggested fix:**
- Replace all `=>` arrow functions with `function(){}` syntax.
- Replace `"` string literals with `'` single quotes wherever possible.
- For double-quote characters needed at runtime (e.g., building `data-t="X"` search strings), use `String.fromCharCode(34)` assigned to a variable: `var q=String.fromCharCode(34)`.
- Avoid async/await (uses no `>`, but it is verbose); use `.then()` chains instead.
