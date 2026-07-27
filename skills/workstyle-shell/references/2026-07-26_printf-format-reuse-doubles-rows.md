---
class: principle
---

**Rule** — `printf` re-runs its format string whenever the arguments outnumber the
conversion specifiers. Make the argument count an exact multiple of the specifier count:

```sh
printf '%s=%s\n' a 1 b 2    # 2 rows: a=1 / b=2   — format applied twice, rc=0
printf '%s\n'    x y z      # 3 rows: x / y / z
printf '%s=%s\n' a 1        # 1 row               — matched arity
```

**Why** — rc=0, empty stderr, and every emitted row is well-formed, so nothing about the
output's shape marks the surplus as unintended. The result is a **plausible wrong count**,
which this skill already holds to be worse than a missing one.

**Inverse polarity to every other silent-failure rule here — this is why it earned its own
bullet rather than a cross-reference.** The false zero, the `-lc` capped count, the
reparsed glob qualifier, the ERE `\|`, the wrapped-prose miss: all of them drive a count
*down*. This one drives it *up*. That inversion defeats the standard remedy directly — a
row-counting probe reporting `2` where the loop body ran once is precisely the shape a
positive control is hoping to see, so the check installed to prove the scan was live is the
check this bug satisfies fraudulently, and "confirm the count changed" clears while the
number is false. Folded next to the wrapped-prose rule so the counting family closes on its
own inverse instead of leaving the reader with a zero-only mental model.

**Verified against source** — Drove the two- and one-specifier cases directly against
surplus arguments, capturing exit status with a direct `$?` rather than a pipeline. 2
specifiers / 4 arguments → 2 rows; 1 specifier / 3 arguments → 3 rows; rc=0 with empty
stderr in both. Positive control in the same invocation form: matched arity → exactly 1
row, confirming the multiplication tracks the argument surplus and not the harness. Cross-
checked the `bash` builtin, the `zsh` builtin, `/bin/sh`, and `/usr/bin/printf` — all four
emit 2 rows for the 2-specifier / 4-argument case, so this is language semantics rather
than a vendor split and no portability branch would intercept it.

**Deliberately omitted from the skill body — the zero-specifier case** — A format
containing no conversion specifier at all was observed to print exactly once with the
surplus arguments discarded (`printf 'literal\n' a b` → 1 row), a third distinct wrong
count from the same call shape. Left out because POSIX declares this case's result
*unspecified*: asserting the observed bash/zsh behavior as portable fact would over-claim
inside a skill whose entire subject is portability, and the prescribed remedy (exact-multiple
arity) already covers it. Recorded here so the omission is not re-litigated as a gap, and so
a future run that finds a platform diverging here knows the case was examined, not missed.

**Where** — wk-workstyle-shell → Rules: new bullet after the hard-wrapped-prose rule,
closing the counting family.

**Ownership note** — Subject is a shell builtin with no dedicated skill or learnings dir;
routed to the skill owning shell-portability and silent-count mechanics. Extended that
skill's existing uncommitted fold and advanced its single version bump rather than opening a
competing one.
