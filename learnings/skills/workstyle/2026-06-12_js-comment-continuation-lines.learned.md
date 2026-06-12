---
skill: wk-workstyle
date: 2026-06-12
type: correction
severity: medium
---

Multi-line JS comment blocks must have `//` on every continuation line.

**What happened:** When editing a multi-line comment block in a JS file, continuation lines lost their `//` prefix. The result was syntactically-valid JS (bare expressions, label syntax) that passed `node --check` but would throw at runtime — `for` without parens is a syntax error, `From:` parses as a label.

**Root cause:** The edit tool replaced the comment block and the replacement omitted `//` from lines 2–4. The JS parser accepted most continuation lines as valid expressions (e.g. an identifier or a label), so `node --check` did not catch it.

**Suggested fix:** After any edit to a multi-line `//`-comment block in JS/TS, scan every added/modified line for the pattern: if the previous line starts with `//` and the current line does not start with `//` but appears to continue the comment (starts mid-sentence, starts with a tab/space, or follows the block's indentation), flag it as a missing `//`.
