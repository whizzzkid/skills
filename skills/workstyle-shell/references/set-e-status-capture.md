---
class: principle
---

**Rule** — In a `set -e` script, capture a command's possibly-non-zero exit with `cmd || status=$?` (initialize `status=0` first), never `cmd; status=$?`.

**Why** — Under `errexit`, the `;` separator does not suppress the exit-on-error: a command returning non-zero terminates the script before the separate `status=$?` assignment runs, so the captured status is never set. Only `||` suppresses `errexit` on its left operand. A helper that legitimately returns non-zero (e.g. 2 for a tolerated skip) makes the whole script exit 2.

**Where** — Shell-script review. Flag any `cmd; status=$?` in a script with `set -e`.
