---
class: principle
---

**Rule** — Never let a line-oriented matcher's zero stand over hard-wrapped prose. `grep`'s
matching unit is the line, so a needle spanning a hard wrap can never hit:

```sh
# file wraps: "...route grep to a" \n "different implementation when needed"
grep -c 'route grep to a different implementation' f     # 0, rc=1  — FALSE zero
tr '\n' ' ' < f | tr -s ' ' | grep -c 'route grep to a different implementation'   # 1, rc=0
```

**Why** — Silent at rc=1 with empty stderr and a valid pattern, so the miss is
indistinguishable from genuine absence. The zero is *load-bearing* wherever it certifies
"not stated here" — a coverage proof gating a deletion inverts on a false zero, discarding
content the proof was supposed to protect. The mismatch is **systematic, not occasional**:
prose files are hard-wrapped to a column budget by convention while the phrases quoted out
of them are not, so any multi-word needle longer than the columns remaining on a wrapped
line is unmatchable by construction. It fails the same way every time, which is why it
survives a re-run and reads as a stable fact.

**Verified against source** — Reproduced directly rather than inferred. Built a two-line
fixture splitting a needle across a hard wrap: line-oriented `grep -c` → `0`, rc=1;
newline-normalized (`tr '\n' ' ' | tr -s ' '`) → `1`, rc=0; a deliberately-absent control
through the identical normalized pipeline → `0`, rc=1, proving normalization had not simply
made everything match. Corroborated live in the same pass — the routing sweep for this
learning was first run line-oriented and re-run normalized, with both a must-hit and a
must-miss control, before its zero was allowed to stand as "no existing coverage".

**Both controls are required, not just the positive one** — Normalization is itself a
transform that can fail in the opposite direction: collapsing newlines can join text the
needle relied on being separate, converting a false zero into a false *positive*. The
existing family rule ("prove any zero with a positive control") is necessary but not
sufficient here, because the remedy for this bug introduces a new failure mode of its own.
Hence a must-hit **and** a must-miss control, both in the normalized invocation form — the
same "run the control in the same invocation form as the scan" requirement the family rule
already states, applied to the normalized pipeline rather than the raw one.

**General form** — The matcher's unit must be at least as large as the needle. Stated this
way it covers the non-`grep` instances of the same shape (line-oriented `awk` rules,
`comm`/`diff` line semantics) without naming them.

**Where** — wk-workstyle-shell → Rules: a new bullet after the `grep -lc` rule, keeping the
matcher-dialect and silent-zero traps adjacent, and mirrored into the README's
"Rules at a Glance".

**Ownership note** — The `skill:` field named `wk-grep`; no such skill or `skills/grep/`
dir exists, so it was treated as the reporter's guess rather than a resolved target. Routed
by subject grep to the skill already owning the silent-failure / matcher-dialect family —
the same routing both siblings took (ERE `\|` literal pipe, `grep -lc` capping at 1).
Extended that fold's existing uncommitted edit and advanced its single version bump rather
than opening a competing one.
