---
class: principle
---

**Rule** — Never write `\|` alternation in a BRE. Pass `-E` and use `(A|B)`:

```sh
sed -E 's/^(A|B): //'     # portable
sed 's/^\(A\|B\): //'     # silent no-op on BSD/macOS
```

**Why** — POSIX BRE has no alternation operator. BSD/macOS `sed` reads `\|` as a
**literal pipe**, so the pattern matches only the three-character run `A|B` and every
intended line passes through byte-identical at rc=0 with empty stderr. GNU `sed`
implements `\|` as an extension, so the script strips correctly on Linux CI and
silently no-ops on macOS.

**Verified against source** — Drove BSD `sed` directly. `s/^\(FLAT\|NESTED\): //` over
`FLAT: a.md` / `NESTED: b.md` returned all three input lines unchanged, rc=0. The
literal reading was proven positively, not merely inferred from the no-op: the
contrived input `FLAT|NESTED: z.md` **is** stripped to `z.md` by the same expression,
which only the literal-pipe interpretation explains. `sed -E 's/^(A|B): //'` stripped
all lines correctly, isolating the dialect as the variable.

**Sharpened from the report** — The report gave the cause as BSD `sed` *rejecting* the
`\|` alternation. The reproduction voids that: there is no rejection, no diagnostic,
and no non-zero status — the expression is accepted and quietly means something else.
Stating it as a rejection would have sent a future reader hunting for an error message
that is never emitted, so the rule is written against the silent reinterpretation.

**Sibling divergence — a third failure class, not a repeat** — The family now holds
three distinct shapes, and the distinction decides what catches each:

- The two `awk` traps — silent *at the tool*: valid program, empty stderr, status 0,
  producing an **empty** result. A positive control catches them.
- The `sed` `q}` trap — loud at the tool (rc=1 plus a diagnostic), silenced only by a
  `$(…)` call site that discards status. Catching it additionally requires branching
  on status.
- This trap — silent at the tool **and** at the call site, producing a *wrong result*
  rather than an empty one. Status is clean and output is non-empty, so neither a
  status branch nor a mere non-empty check fires; only a control asserting the
  transform actually changed something detects it.

Recorded because "check which failure mode you are documenting" is the operative step:
reaching for a diagnostic on this one finds nothing and wrongly clears the tool.

**Observed blast radius** — Used to strip a label prefix before a `comm` comparison, the
surviving prefix made every left-hand entry miss its counterpart, so an entire source
reported as wholly unprocessed. The unanimity of that verdict was the only signal that
indicted the tooling — consistent with the existing rule that a unanimous verdict
indicts the harness before the artifact.

**Where** — wk-workstyle-shell → Rules: immediately after the existing `sed -i`
portability bullet, keeping the `sed` cluster contiguous.

**Ownership note** — Routed by subject to the skill that already owns the
silent-failure / portability family; extended that fold's existing uncommitted edit and
advanced its single version bump rather than opening a competing one. No `wk-sed` skill
exists, and the BSD `sed` rules already live here.
