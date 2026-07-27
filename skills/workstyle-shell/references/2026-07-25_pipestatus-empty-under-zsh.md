---
class: principle
---

**Rule** — Never read `${PIPESTATUS[…]}` in a snippet that may run under zsh. Capture a
status-bearing probe without a pipeline instead: redirect output to a file and read `$?`,
or run the command bare. Treat a guard whose verdict contradicts the output it summarizes
as an indictment of the guard, not of the output.

**Why** — `PIPESTATUS` is bash-only; zsh spells it `pipestatus` (lowercase) and leaves the
uppercase name unset. Verified by driving both shells: after `true | false`,
`${#PIPESTATUS[@]}` is `0` under zsh (while `pipestatus` holds `0 1`) and `2` under bash.
So `rc=${PIPESTATUS[0]}` expands empty, the customary `${rc:-0}` default supplies a success
code, and the guard prints a pass. This is the *inverting* member of the silent-failure
family rather than the emptying one: the awk PCRE-escape and `END`-exit traps yield a false
zero, whereas this yields a false green — strictly worse, because a zero at least invites
the "did my matcher work?" question while an affirmative verdict closes it. The failure
survives `set -euo pipefail`: an unset array with a `:-` default is neither an error nor a
warning, and exits 0.

**Where** — `wk-workstyle-shell` → Rules → the zsh-portability rule, as its third trap
alongside `for x in $LIST` and `${!var}`.

## Found but deferred — an over-general instance elsewhere (DISCHARGED 2026-07-27)

**Discharged** in the pass that folded `2026-07-27_pipe-steals-the-verdict.md`: the
tree was clean and `wk-workflow` unclaimed, so both instances below were corrected.
The SKILL bullet now prescribes bare-or-redirect and names `${PIPESTATUS[0]}` only
to forbid it; the paired reference carries a `Corrected 2026-07-27` note.

- `wk-workflow`'s authoritative-gate rule (and its paired reference) prescribes reading
  `${PIPESTATUS[0]}` unqualified as the remedy for `$?`-after-a-pipe. Under zsh that
  advice produces exactly this false pass. The rule does offer a portable alternative
  (redirect to a file, check `$?`), so it is under-qualified rather than wrong.
- Not corrected in this pass: the commit gate was blocked, and `wk-workflow` was a clean,
  unclaimed path. Opening an unlandable sixth fold there would entangle a shared tree,
  which `SKILL.md` forbids ("a blocked commit gate defers rather than folding harder").
  Scheduled for the next run once signing recovers.
