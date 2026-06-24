---
class: principle
---

**Rule** — After writing or editing a Go file, run the formatter in *write* mode
(`goimports -local <module> -w <file>`) before staging. Do not use the *list* mode
(`-l`) as a pass/fail gate.

**Why** — `-l` only prints the names of files that need fixing; it never rewrites
them. Treating empty `-l` output as "clean" produces a false pass when the file was
never run through `-w`, and the CI format gate (which applies the equivalent of `-w`)
then rejects import grouping / trailing-comment alignment. `go test` does not catch
these.

**Where** — wk-pr-resolve "For each fix" verification step; any skill step that stages
a Go file.
