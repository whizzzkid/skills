---
class: principle
---

**Rule** — Never encode a verdict in an `awk` rule body's `exit N` when the program also
has an `END` block that exits with an argument. Set a flag in the rule body, exit
arg-less, and let `END` compute the status:

```awk
/qualifies/ { ok = 1; exit }   # stop reading, fall into END
END { exit !ok }
```

**Why** — `exit` inside a rule body does not terminate the program. It stops reading
input and *falls through to `END`*. An argument-bearing `END { exit 1 }` then replaces
the rule body's status, so the qualifying and rejecting branches converge on the same
exit code — a silent, confidently-wrong all-reject. The program is syntactically valid,
writes nothing to stderr, and the broken verdict is indistinguishable from a real one.

**Verified against source** — Driving `awk` directly: `printf 'a\n' | awk '{exit 0}
END{exit 1}'` returns rc=1, while the same program without the `END` block returns rc=0,
and an `END` `print` proves the block still runs after the rule-body `exit`. The
prescribed form returns rc=0 on a qualifying input and rc=1 on a rejecting one.
Behaviour is identical under BSD `awk` and `gawk`, so this is POSIX semantics rather than
a vendor quirk.

**Sharpened from the report** — The reporter described the mechanism as "`END` overrides
the rule-body status". The reproduction narrows it: an **arg-less** `exit` in `END`
*preserves* the rule-body status (`awk '{exit 3} END{exit}'` returns rc=3). Only an
argument-bearing `END` exit overrides, so the rule is stated against that shape.

**Corollary** — This is the second distinct silent-zero mechanism in `awk` (the first:
PCRE shorthand escapes degrading to escaped literals). Both share one detection: never
accept an `awk` zero / all-reject result without a positive control that moves the count.
That corollary was hoisted out of the escape rule into its own bullet so it governs both.

**Where** — wk-workstyle-shell → Rules, immediately after the PCRE-escape trap, with the
shared positive-control corollary as the following bullet.

**Ownership note** — Filed under `skill: wk-awk`, which has no on-disk directory. Routed
by subject to the skill whose body already owns the `awk` silent-failure / portability
family, matching where the sibling escape finding landed. A dedicated `awk` skill is a
judgment call for the dispatcher, not a unilateral creation.
