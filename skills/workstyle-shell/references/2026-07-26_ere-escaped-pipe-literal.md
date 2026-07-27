---
class: principle
---

**Rule** — Never escape `|` in an ERE. Under `-E`, alternation is the bare metacharacter;
`\|` is a literal pipe:

```sh
grep -rE 'alpha|beta' dir/      # alternation
grep -rE 'alpha\|beta' dir/     # dead: one literal `alpha|beta`, matches nothing
```

**Why** — A backslash makes `|` ordinary, so `'a\|b\|c'` under `-E` is not "a or b or c"
but the single literal `a|b|c`. Every alternative is lost in one keystroke. The pattern
stays syntactically valid, stderr is empty, and the status is a plain rc=1 — so the
failure presents as a clean **unanimous zero** rather than an error, indistinguishable
from genuine absence.

**Verified against source** — Drove BSD grep 2.6.0 (GNU-compatible) directly over a
four-line fixture. `grep -cE 'alpha\|beta'` returned 0/rc=1 while `grep -cE 'alpha|beta'`
returned 2, isolating the escape as the variable. The literal reading was proven
positively rather than inferred from the zero: the contrived line `a|b` **is** matched by
`grep -cE 'a\|b'` (1 hit), which only the literal-pipe interpretation explains.

**Dialect inversion — scope of the BRE sibling** — The two characters mean opposite things
across the dialects, so the habit disables the match carried in either direction. The
existing BRE rule in this skill is scoped to `sed`, and that scope is correct as written:
the same probe showed this BSD *grep* does honor `\|` as alternation in BRE (2 hits),
GNU-extension behavior that BSD `sed` does not share. So "BRE `\|` is a literal" is a
`sed`-and-POSIX-strict fact, not a blanket one — whereas "ERE `\|` is a literal" is
universal. The two rules were kept adjacent but not merged for exactly this reason;
collapsing them would over-generalize the BRE arm.

**Failure-class placement** — Silent at the tool *and* at the call site, like the BSD `sed`
BRE trap, but producing an **empty** result rather than a wrong one. That puts it back in
reach of an ordinary positive control (unlike the `sed` case, which needs a control
asserting the transform changed something) — provided the control runs in the same
invocation form and is itself proven live.

**Observed blast radius** — Two verification greps checking whether a set of records
existed both returned zero across ~40 files, and the run came one step from reporting the
records missing — a false gap that would have driven manufactured work to restore what was
never gone. Re-running one pattern with a bare `|` returned 13 hits, proving the pattern
dead rather than the data absent. The unanimity across independent patterns was the only
signal that indicted the syntax, consistent with the existing rule that a unanimous
verdict indicts the harness before the artifact.

**Encountered live this run** — While routing this very learning, a positive control
(`grep -c 'HARD RULE'` against the target skill) returned 0 — matching its nonsense-term
counterpart exactly. The control term simply is not in that file; the control was dead and
certified nothing. Re-run with a term confirmed present, it returned 1. A control is only a
control once it has moved the count.

**Where** — wk-workstyle-shell → Rules: immediately after the BSD `sed` BRE-alternation
bullet, keeping the dialect pair adjacent.

**Ownership note** — The `skill:` field named `wk-grep`; no such skill or `skills/grep/`
dir exists, so it was treated as the reporter's guess. Routed by subject grep to the skill
already owning the silent-failure / regex-dialect family, which holds the BRE arm of this
exact inversion. Extended that fold's existing uncommitted edit and advanced its single
version bump rather than opening a competing one.
