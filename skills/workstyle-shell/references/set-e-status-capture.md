---
class: principle
---

**Rule** — In a `set -e` script, capture a command's possibly-non-zero exit with `cmd || rc=$?` (initialize `rc=0` first), never `cmd; rc=$?`. Name the variable `rc`, never `status` (read-only under zsh: the assignment aborts).

**Why** — Under `errexit`, the `;` separator does not suppress the exit-on-error: a command returning non-zero terminates the script before the separate `rc=$?` assignment runs, so the captured status is never set. Only `||` suppresses `errexit` on its left operand. A helper that legitimately returns non-zero (e.g. 2 for a tolerated skip) makes the whole script exit 2.

**Where** — Shell-script review. Flag any `cmd; rc=$?` (any variable name) in a script with `set -e`.
