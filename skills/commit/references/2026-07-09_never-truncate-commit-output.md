---
skill: wk-commit
class: principle
---

**Rule** — Never pipe `git commit` through a short `| tail -N` that can drop the
hook's `✗`/error block and the `[branch sha]` success confirmation together.
Show full output or append `&& echo OK`, and confirm HEAD advanced
(`git rev-parse HEAD`, or `git log --oneline -1`).

**Why** — When a pre-commit hook aborts, `tail -N` can hide both the failure
message and the missing confirmation line, so a blocked commit is
indistinguishable from a successful one. Observed: a `2>&1 | tail -3` on a
hook-blocked commit ended on a still-running hook glyph, read as success, but
HEAD had not moved and files were still staged.

**Where** — wk-commit Hook and verify rules.
