---
class: principle
---

**Rule:** In the Step 5 overfit scan, grep proposed edit text against
`[A-Z][A-Z0-9]+-\d+`. Any match — including invented illustrative
placeholders — trips the `check-ticket-refs` pre-commit hook, which matches on
shape, not provenance. Replace with an angle-bracket placeholder
(`<child-key>`, `<KEY>`) or the repo's `BOARD-NUM` form.

**Why:** "Specific ticket IDs" was already a scan category, but it read as
covering only real tracker IDs. Example tokens shaped like a key look safe yet
still match the hook regex and block the commit.

**Where:** Step 5, Mechanical overfit scan.
