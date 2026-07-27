---
class: principle
skill: wk-workstyle-shell
date: 2026-07-25
severity: high
---

**Rule** — State the zsh no-word-splitting trap as a property of unquoted **parameter
expansion in any position**, not as a `for`-loop trap. `cmd $FILES` hands the tool one
argument containing every element, exactly as `for x in $LIST` runs the body once over the
whole blob.

**Why** — The bullet previously led with `for x in $LIST`, so it read as a *loop* hazard.
An agent composing `cmd $VAR` in argument position does not pattern-match a loop rule, and
the failure then arrives as a plausible domain error — `No such file or directory`, or an
empty match set — rather than a syntax error, so it is accepted as a real result.

**Escalation — one notch, rung 1 → rung 2 (`**Important:**`).** Justified: this rule was
re-violated while **in force**. Verified rather than assumed — the installed skill carries
the word-splitting bullet verbatim, so the violations were not against unshipped text.
Two independent re-violations, the second occurring mid-run in a session whose own task
brief warned about this exact trap, during a scan whose zero result was load-bearing.

**Distinguish from the sibling rule that did NOT earn a notch** — the *ad-hoc command*
strengthening on the parent bullet was present only in the working tree, absent from the
installed skill. A re-violation cannot indict a rule that never shipped; only the
in-force bullet was escalated. Check installed-vs-worktree text before crediting any
re-violation to a fold.

**Also note** — escalation alone would not have prevented recurrence here: the defect was
the rule's *shape*, not its volume. The framing fix (any position, not just `for`) is the
load-bearing half; the notch records the repeat.

**Where** — Rules list, zsh-portability trap family, first trap.
