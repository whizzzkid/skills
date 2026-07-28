---
class: principle
---

# `awk` `ENVIRON[]` is disjoint from `-v` / `var=val` assignment

**Rule** — `ENVIRON[]` exposes only the *process* environment. A `-v name=val` option and a
command-line `name=val` operand assign an ordinary `awk` variable in a separate namespace that
`ENVIRON[]` never sees. `export` anything intended to be read through `ENVIRON[]`, or read a
`-v` variable by its bare name.

**Why** — the mismatch fails silently in the direction that manufactures a *pass*. The lookup
expands to the empty string with a valid program, empty stderr, and rc=0; the empty value then
propagates as a plausible one rather than an error. `substr($0, start, ENVIRON["LEN"])` with an
empty length returns a zero-length string, and a zero-length needle makes `grep -qF -e ""`
match every input — so a per-item check reports a unanimous OK it never performed. This is the
**inverse polarity** of the two `awk` traps already documented above it: those manufacture a
silent zero, which at least looks like a finding worth checking, whereas a unanimous pass reads
as corroboration and prompts no investigation at all.

**Where** — `SKILL.md` → Rules → immediately after the `exit N` / `END` trap, keeping the three
`awk` traps contiguous and ahead of the `command`-prefix and positive-control rules.

## Verification

Driven directly against `/usr/bin/awk` on macOS, all three arms in one script:

- `awk '…' CUTLEN=5 f` reading `ENVIRON["CUTLEN"]` → empty, `length()` = 0.
- `awk -v CUTLEN=5 '…' f` → `ENVIRON["CUTLEN"]` empty, bare `CUTLEN` = 5 (confirms the two
  mechanisms are disjoint rather than the value being lost).
- `CUTLEN=5 awk '…' f` → `ENVIRON["CUTLEN"]` = 5.
- Downstream harm reproduced end-to-end: the empty length yielded a zero-length needle, and
  `grep -qF -e ""` returned rc=0 against unrelated text where a real needle returned rc=1.

## Report claim corrected

The field report asserted that existing guidance already "prefers `ENVIRON[]` over `-v` for
anchors carrying escape sequences" and that the gap was merely a missing warning that the two
are disjoint. **Disproven**: a repo-wide search found zero occurrences of `ENVIRON` in any
file, against same-invocation-form positive controls returning 19 and 36 hits. No such
preference was ever documented, so the fold was derived from the reproduced semantics as a
standalone rule rather than written as an amendment to a non-existent bullet.

## Recount checked, no drift

The positive-control bullet's enumeration ("the two `awk` ones") was re-derived from source and
**left at two**: it scopes itself to *status-0 silent-zero* mechanisms, and this trap produces a
unanimous pass, not a zero. Precedent is the `printf` row, which is likewise inverse-polarity
and likewise excluded from that count. The word "silent-zero" carries the disambiguation.

## Byte arithmetic

Body 21052 → 22076, net **+1024 B**, ceiling 24576 (2500 B clear). Headroom before the fold was
3524 B, comfortably over 2× the edit, so no reclaim was budgeted or taken — the measure-before-
drafting rule was satisfied by the pre-edit measurement, not waived.

## Worked example

Relocated from `SKILL.md` (same bullet) to hold the body under the size ceiling. The
imperative stays inline under a cut-site pointer, so the rule is still reachable where it
was; only the demonstration and the inverse-polarity rationale moved.

```bash
awk '{ print ENVIRON["LEN"] }' LEN=5 f   # WRONG — empty; operand is not in the environment
LEN=5 awk '{ print ENVIRON["LEN"] }' f   # CORRECT — exported into the process environment
```
