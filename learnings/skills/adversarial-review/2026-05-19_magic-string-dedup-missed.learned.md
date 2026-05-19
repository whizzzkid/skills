---
skill: wk-adversarial-review
date: 2026-05-19
type: gap
severity: low
---

Removing a constant without extracting a replacement leaves magic-string duplicates.

**What happened:** A PR removed a package-level constant (`repoChecksDir`)
as "unused" but the string it held was then inlined identically at three
call-sites across two files. The bot reviewer caught it; adversarial review
did not.

**Root cause:** Sweep 2.1 (vulnerability-class) looks for security patterns.
There is no sweep that checks: "was a constant removed while its literal
value appeared in the diff at multiple sites?"

**Suggested fix:** Add to sweep 2.1 or as standalone sweep: for each removed
`const X = "..."` or equivalent, grep the full diff for the literal string
value. If it appears at 2+ non-comment sites in the post-rebase code,
flag as `suggestion` (magic-string duplication, consider extracting helper).
