---
skill: wk-awk
date: 2026-07-25
type: surprise
severity: medium
verified-against-source: yes
---

`awk` silently matches nothing when a pattern uses PCRE shorthand escapes like `\S` / `\d` / `\w`.

**What happened:** A frontmatter gate used `/^[[:space:]]*type:[[:space:]]*\S/` to require a
non-empty `type:` value. It matched zero of nine files that all plainly contained `type:` at column
0. The gate reported every file as failing to parse, which read as a real (and alarming) result
rather than a broken matcher.

**Root cause:** POSIX ERE — which `awk` implements — has no `\S`, `\d`, `\w`, or `\b` shorthand.
Confirmed by driving `awk` directly: replacing `\S` with the POSIX class `[^[:space:]]` took the
same nine files from 0 matches to 7. Rather than erroring on the unknown escape, `awk` treats `\S`
as an escaped literal `S`, so the pattern quietly becomes "`type:` followed by whitespace then a
literal `S`" — it stays syntactically valid and fails silently. There is no warning on stderr and
the exit status is 0.

**Suggested fix:** In any `awk` pattern, use POSIX bracket expressions, never PCRE shorthand:

- `\S` → `[^[:space:]]`, `\s` → `[[:space:]]`
- `\d` → `[0-9]`, `\w` → `[A-Za-z0-9_]`

Because the failure is silent and status-0, never accept an `awk` filter's zero/all-reject result
without a positive control — feed it one input known to match and confirm the count moves. Reach for
`grep -E` or `perl` when genuine PCRE semantics are required.
