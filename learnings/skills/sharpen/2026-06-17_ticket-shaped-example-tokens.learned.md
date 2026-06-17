---
skill: wk-sharpen
date: 2026-06-17
type: gap
severity: medium
---

Example placeholder tokens shaped like ticket keys (a key prefix followed by
`-` and a digit) trip the `check-ticket-refs` pre-commit hook and block the
commit.

**What happened:** A sharpen edit added an illustrative prompt listing two
key-shaped child tokens. The hook flagged both as internal tracker IDs and
rejected the commit; a re-edit to angle-bracket placeholders (`<child-key>`)
was needed.

**Root cause:** The Step 5 mechanical overfit scan lists "specific ticket
IDs" as a category but does not call out invented example tokens that
merely *match the ticket regex* (`[A-Z][A-Z0-9]+-\d+`). Illustrative
placeholders read as safe but the hook matches on shape, not provenance.

**Suggested fix:** In the overfit scan, require ticket-shaped example
tokens to use angle-bracket placeholders (`<child-key>`, `<KEY>`) or the
repo's `BOARD-NUM` form — never a literal matching `[A-Z][A-Z0-9]+-\d+`.
Grep proposed edit text against that regex before presenting the diff.
