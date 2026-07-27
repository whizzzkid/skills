---
skill: wk-workstyle-shell
date: 2026-07-26
type: surprise
severity: high
verified-against-source: yes
---

BSD `sed` silently reinterprets BRE `\|` as a literal pipe, so a prefix-stripping
substitution is a no-op that returns rc=0 and a wrong result.

**What happened:** A marker-diff harness normalized its left-hand list with
`sed 's/^\(FLAT\|NESTED\): //'` to strip a label prefix before `comm`. The strip
never occurred, every left-hand entry kept its prefix, and `comm -23` therefore
matched nothing on the right — reporting 100% of the source as un-distilled. The
unanimous verdict was the only reason the tooling was suspected at all.

**Root cause:** In POSIX BRE, `\|` is not alternation. BSD/macOS `sed` treats the
escaped pipe as a **literal `|` character**, so `\(FLAT\|NESTED\)` matches the
8-character string `FLAT|NESTED` and nothing else. Driven directly: the intended
inputs pass through byte-identical with rc=0 and empty stderr, while the
contrived input `FLAT|NESTED: z.md` *is* stripped to `z.md` — proving the literal
reading rather than a rejected pattern. GNU sed implements `\|` as an alternation
extension, so the same script is correct on Linux and wrong on macOS.

**Suggested fix:** Record this as a *wrong-result* portability trap, distinct
from the loud-abort BSD sed traps already documented (`q}` aborts the script;
`sed -i` consumes its script as a suffix). Those fail with a diagnostic; this one
produces a plausible, unflagged, exit-0 result, so no error surfaces and the
wrong output is consumed as data. Rule: never use `\|` in a BRE — pass `-E` and
write `(A|B)`. More generally, treat any *no-op* substitution as indistinguishable
from a correct pass-through, and gate any load-bearing normalization on a positive
control that proves the transform actually fired.
