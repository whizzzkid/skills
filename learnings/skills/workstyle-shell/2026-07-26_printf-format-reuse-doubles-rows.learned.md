---
skill: wk-workstyle-shell
date: 2026-07-26
type: surprise
severity: medium
verified-against-source: yes
---

`printf` silently re-runs its format string when the arguments outnumber the conversion
specifiers, multiplying the output rows at rc=0.

**What happened:** A probe emitting one row per record produced twice as many rows as
records. Nothing in the output marked the surplus — every row was well-formed — so the
inflated count read as a larger-than-expected but plausible result rather than a defect.

**Root cause:** POSIX `printf` consumes the argument list in passes: when arguments remain
after the format is exhausted, the format is applied again from the start. Driven directly:

```
printf '%s=%s\n' a 1 b 2   ->  2 rows:  a=1 / b=2      (rc=0, stderr empty)
printf '%s\n'    x y z     ->  3 rows:  x / y / z      (rc=0, stderr empty)
printf '%s=%s\n' a 1       ->  1 row               # control: matched arity
```

Identical across the `bash` builtin, the `zsh` builtin, `/bin/sh`, and `/usr/bin/printf`
(all four emit 2 rows for the 2-specifier/4-argument case), so it is language semantics, not
a vendor quirk, and there is no platform on which a portability branch would catch it.

**Why it is dangerous rather than merely surprising:** every other silent-failure mechanism
catalogued in this skill produces a count that is too *low* — a false zero, a capped count,
an all-reject. This one runs the opposite direction. A row-counting probe that reports `2`
where the loop body ran once looks like *corroboration*: it is the shape a positive control
is hoping to see, so the very check meant to prove the scan was live is the check this bug
satisfies fraudulently. The existing "a plausible wrong number is worse than a missing one"
rule applies with its sign flipped, and the existing "confirm the count changed" remedy is
defeated, since the count did change — by too much.

**Also observed (not folded into the rule):** a format containing *no* conversion specifier
at all is printed exactly once and the surplus arguments are discarded — a third distinct
wrong count from the same call shape. Left out of the skill body deliberately: POSIX
declares this case's result *unspecified*, so asserting the observed bash/zsh behavior as a
portable fact would over-claim in a skill whose subject is portability.

**Suggested fix:**

- Make the argument count an exact multiple of the specifier count — ideally 1×, one record
  per call.
- Where a line is assembled from a variable number of pieces, build it in a variable and
  emit it with a single `printf '%s\n' "$line"`.
- Never treat a row count from a `printf`-built stream as evidence without knowing the call's
  arity.
