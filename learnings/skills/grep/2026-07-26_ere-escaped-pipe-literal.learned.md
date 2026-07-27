---
skill: wk-grep
date: 2026-07-26
type: surprise
severity: high
verified-against-source: yes
---

Under `grep -E`, `\|` is a literal pipe — escaping it silently kills alternation and returns a unanimous zero.

**What happened:** Two verification greps were run to check whether a set of records existed:

```bash
command grep -rlE 'blocked.*gate\|MUST-FOLD\|Ownership resolves' <dir>/
command grep -rlE 'worktree\|landing' <dir>/
```

Both returned zero across ~40 files, and the run was one step from reporting the records as
missing — a false gap that would have driven manufactured work. Re-running the second pattern
with a bare `|` returned 13 hits, proving the original pattern had been dead, not the data absent.

**Root cause:** In ERE, alternation is the bare metacharacter `|`; a backslash makes it an
ordinary literal. So `'a\|b\|c'` under `-E` does not mean "a or b or c" — it collapses into the
single literal string `a|b|c`, which matches nothing. Every alternative is lost in one move, so
the failure presents as a clean, uniform zero rather than a syntax error.

This is the exact inverse of the BRE convention (`sed`, `grep` without `-E`), where the bare `|`
is a literal and `\|` is the alternation operator — and in some BRE implementations `\|` is not
alternation at all but simply a literal pipe. The same two characters mean opposite things across
the two dialects, so carrying the habit from a BRE tool into an ERE invocation disables the match
silently, with no diagnostic.

**Suggested fix:**

- In any `-E` / `-r` (ERE) pattern, write alternation as a bare `|`; never escape it. Reserve
  `\|` for when a literal pipe character is genuinely wanted.
- Because a dead alternation **fails closed**, it is indistinguishable from a genuine absence.
  Any alternation-based grep whose *zero* is load-bearing must be proven live before the zero is
  read as a verdict: pair it with a positive control — a term known to be present — in the same
  invocation form, and confirm the control actually returns a hit.
- Treat a zero that is unanimous across several independent alternation patterns as an
  indictment of the pattern syntax first, and of the data only after the control fires.
