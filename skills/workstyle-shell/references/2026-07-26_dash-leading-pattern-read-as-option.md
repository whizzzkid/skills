---
class: principle
---

**Rule** — Never pass a variable pattern as a bare `grep` operand; bind it with
`grep -e "$pat"`. A pattern beginning with `-` is parsed as options before anything is
treated as a pattern:

```sh
grep "-Werror" hay.txt     # rc=2  grep: invalid option -- W        (loud)
grep "--color" hay.txt     # rc=1  empty stdout, empty stderr       (silent)
grep -e "-Werror" hay.txt  # rc=0  -Werror is set here
```

**Why** — The failure is **bimodal and only one mode is loud**. An unrecognized letter
aborts at rc=2 and diagnoses itself. But a pattern that happens to *be* a valid option is
consumed as one; the file operand then slides into the pattern slot, no file operand
remains, and `grep` reads **stdin** — rc=1, empty stdout, empty stderr. Because a MISSING
verdict keys on rc=1 rather than rc=2, this branch scores a needle absent purely for its
first character, indistinguishable from genuine absence. With stdin on a terminal the same
branch blocks instead of returning.

**Verified against source** — Drove a three-line fixture whose second line is
`-Werror is set here`, `command`-prefixed so the shell's `grep` could not re-exec a
different engine. Bare `-Werror` → rc=2 with `invalid option -- W`; bare `--color`, `-e`,
and `-x` → rc=1 with both streams empty; `-e "-Werror"` and `-- "-Werror"` → rc=0 with the
line. Positive control in the same invocation form: bare `beta` → rc=0, proving the
haystack and the invocation shape were sound and isolating the leading `-` as the sole
cause.

**Sharpens the reported mechanism** — The field report described this as "parsed as flags
rather than a pattern", which is true but under-specifies the consequence and points at the
loud half. Reproduction showed the loud half is harmless and the *quiet* half is what
produced the observed false MISSING, and further that the quiet half only arises when the
pattern collides with a **real** flag. Both facts changed the drafted wording: the rule now
leads with the rc=1 branch and names the stdin fallback, rather than the `invalid option`
string a reader would otherwise expect to see in their terminal.

**Distinct from the BSD option-reordering rule it sits beside, and its remedy is not
transferable** — That rule covers a flag written *after* an operand being demoted to an
operand, a BSD-only non-reordering quirk. This is the inverse: an operand written first
being promoted to a flag, and it is plain POSIX parsing that reproduces on GNU identically.
The neighbour's remedy — "put flags before operands" — is actively wrong-footed here, since
the pattern already precedes the operand and that is exactly the defect. Placed immediately
after it so the two read as one option-parsing family with the distinction stated inline,
rather than as a contradiction a later reader has to adjudicate.

**`-e` preferred over `--`, deliberately** — Both fix the reproduction. `--` was not
prescribed as the primary remedy because it demotes *every* later word to an operand, so a
composed invocation carrying a trailing `-r` or `-n` silently converts it to a filename —
trading one operand/flag confusion for another. `-e` binds only the next word and survives
any argument position, which is the property a programmatically assembled command needs.

**Interaction with the positive-control family** — A control needle that itself begins with
`-` certifies nothing: its own rc=1 is read as the control failing to fire, which invites
the conclusion that the harness is broken when the scan is fine. Noted in the learning; not
restated in the skill body, where the existing control rules already carry the general form.

**Where** — wk-workstyle-shell → Rules: new bullet immediately after the macOS/BSD
option-reordering rule.

**Ownership note** — The `skill:` field named `wk-grep`; no such skill or `skills/grep/`
dir exists, so it was treated as the reporter's guess and routed by subject to the skill
already owning the matcher-dialect / silent-failure family — the same routing its four
siblings took. Extended that skill's existing uncommitted fold and advanced its single
version bump rather than opening a competing one.
