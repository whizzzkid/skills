---
skill: wk-workstyle-shell
date: 2026-07-25
type: gap
severity: medium
verified-against-source: no
---

A zsh-only glob qualifier failed as a plausible "directory is empty" error, nearly
producing a false-empty scan result — a fourth portability trap the rule's catalog omits.

**What happened:** An agent enumerating files for a scan composed
`for f in <dir>/**/*.md(N); do …` ad-hoc, relying on the `(N)` nullglob qualifier to make
an unmatched pattern expand to nothing. The qualifier was not honored in the agent's
execution environment: the shell raised `no matches found: <dir>/**/*.md(N)` and the loop
never ran. Re-running the same enumeration with `find <dir> -type f -name '*.md'` piped
into `while IFS= read -r f` listed the files correctly, so the files were present the
whole time.

The danger is the shape of the failure, not the failure itself. `no matches found` is
exactly what a genuinely empty directory would report, and the construct is *meant* to
suppress that error — so the failure mode and the intended success both look like "there
is nothing here". Had the surrounding step tolerated the non-zero status, the scan would
have reported the source as drained. That is the same false-empty, under-reporting
direction that the distilling skill separately flags as the worse failure, because no
visible work is produced and nothing prompts an investigation.

**Root cause:** The existing zsh-portability rule catalogs three traps — unquoted
parameter expansion in `for`, `${!var}` indirect expansion, and `${PIPESTATUS[…]}`. All
three are *bash-only constructs failing under zsh*. This is the mirror case: a *zsh-only*
construct that is not honored, so a reader who checked their command against the three
listed traps finds it clean. Glob qualifiers are absent from the catalog entirely.

`(unverified — inferred from symptom)` why the qualifier was not applied: plausibly a
non-interactive invocation or an option/emulation setting that disables bare glob
qualifiers. Not confirmed against the shell's option state — only the observable behavior
above was reproduced.

**Suggested fix:** Add a fourth trap to the zsh-portability catalog covering
shell-specific glob qualifiers and pattern options (`(N)`, `(.)`, `**` recursion,
nullglob/failglob dependence): never rely on them in a command the agent composes;
enumerate with `find … -print` fed through `while IFS= read -r`, which behaves identically
across shells and does not conflate "no matches" with "pattern unsupported". Note the
mirror-image framing explicitly — the catalog currently reads as "bash-isms break under
zsh", which lets a zsh-ism pass unexamined. Worth pairing with the existing
positive-control requirement, since an enumeration that yields zero is exactly the result
this trap fabricates.
