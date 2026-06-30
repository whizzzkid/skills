---
skill: wk-sharpen
date: 2026-06-30
type: gap
severity: medium
---

Per-file prohibited scan over an unquoted file list can report a false "clean"

**What happened:** Step 5's content scan ran `grep -iEnf .skillprohibit $files`
with `$files` holding a newline-separated staged path list. The active `grep` was
an alias to a stricter matcher that treated the whole multi-line string as a
single path argument, warned `No such file or directory`, matched nothing, and so
the `|| echo "content clean"` branch printed "content clean" — a false negative.
A real prohibited term in any staged file would have been missed.

**Root cause:** Passing a multi-line variable as bare `$files` is fragile: word
splitting and matcher-specific argument handling can collapse it into one
nonexistent path, and a no-match exit then masquerades as a clean scan. The
recipe trusted exit status without confirming the matcher actually opened each
file.

**Suggested fix:** Iterate the staged set per file with a quoted loop
(`while IFS= read -r f; do grep -iEnHf .skillprohibit "$f"; done < <(git diff
--cached --name-only)`), or `git diff --cached --name-only -z | xargs -0`. Treat
any `No such file or directory` warning as a scan failure, not a clean result.
Pair with the existing positive-control probe so a genuine NONE is proven by a
live matcher, not an unread-file zero.
