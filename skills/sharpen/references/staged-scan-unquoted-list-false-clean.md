---
class: principle
---

**Rule:** Run the prohibited-term content scan per-file, NUL-delimited
(`git diff --cached --name-only -z | xargs -0 grep -iEnHf .skillprohibit`), never
as `grep ... $files` over a bare multi-line variable. Treat any
`No such file or directory` warning from the scan as a scan failure, not a clean
result.

**Why:** A multi-line `$files` passed unquoted is fragile: word-splitting plus a
stricter `grep` alias (e.g. an aliased matcher) can collapse the whole string
into one nonexistent path, warn `No such file or directory`, match nothing, and
exit non-zero — the `|| echo "content clean"` branch then prints a false clean,
silently missing a real prohibited term in any staged file. The per-file/NUL form
opens each file individually so a collapse cannot happen.

**Where:** Step 5 mechanical overfit scan, staged-set scan block. Pairs with the
existing positive-control probe — a genuine NONE is proven by a live matcher, not
an unread-file zero.
