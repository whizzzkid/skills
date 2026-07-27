---
class: principle
---

**Rule** — Never pair `-l` with `-c` in one `grep`. Neither flag is rejected; `-l`
short-circuits each file at its first match, so on BSD/macOS the counter is capped at 1:

```sh
grep -rc  term dir/     # b.txt:0  a.txt:2        — true counts
grep -rlc term dir/     # b.txt:0  a.txt:1  a.txt — capped, plus the -l list
```

**Why** — Two independent defects, both silent at rc=0 with empty stderr. First, the count
is **wrong, not absent**: `a.txt:1` is a plausible-looking number that is simply false, so
any threshold, delta, or "did the control move the count" check reading it is consuming a
truncated value. A capped count is more dangerous than a missing one because nothing about
its shape signals corruption. Second, the stream **interleaves both output formats** —
`file:count` lines *and* bare filename lines — so a consumer splitting on `:` silently
mis-parses the bare names. Flag order (`-lc` vs `-cl`) changes nothing.

**Verified against source** — Drove a two-file fixture (one file containing the term twice)
directly, `command`-prefixed so the shell's `grep` alias could not substitute a different
engine. BSD `/usr/bin/grep`: `-rc` → `a.txt:2`; `-rlc` → `a.txt:1` plus a bare `a.txt`
line, rc=0. Reproduced non-recursively and on a single file (`-c` → `2`, `-lc` → `1` plus
the filename), confirming the cap is not an artifact of `-r` or of multi-file mode. `-cl`
behaved identically to `-lc`, isolating the flag *pair* rather than an ordering quirk.

**Platform split runs opposite to this skill's other vendor rules** — GNU grep 3.12
(`ggrep`) does **not** cap: `-l` simply wins and it prints the filename alone, no number at
all. So the malformed shape is loud on GNU (a filename where a count was expected) and
silent on BSD, where it becomes a plausible false integer. Every other vendor rule in this
skill has GNU as the permissive side and BSD as the side that aborts or no-ops; here the
polarity is reversed and macOS is the platform that manufactures corrupt data while Linux
CI looks clean. Recorded because the majority pattern, generalized, predicts the wrong
side — the README's "GNU is not the portable default" note was corrected in the same pass
from a blanket claim to a directional-uncertainty one.

**Extends rather than duplicates the positive-control rule** — The existing family rule
prescribes "feed one input known to qualify and confirm the count changes". That remedy is
**defeated** by this bug in both directions: a capped counter still moves 0 → 1, so the
change criterion clears while the number stays false; and a control asserting "> 1" is
unsatisfiable by construction, presenting as a permanent failure to explain away. The
existing rule's enumeration of *status-0 silent-zero* mechanisms stays accurate and was
left untouched — this is a distinct axis, a silent wrong **non-zero**, so it landed as a
new sub-bullet tightening the pass criterion to a known *true* count.

**Where** — wk-workstyle-shell → Rules: the flag-pair mechanics as a new bullet after the
ERE `\|` rule, keeping the `grep`-dialect traps adjacent; the control-criterion tightening
as a sub-bullet under the positive-control rule it corrects.

**Ownership note** — The `skill:` field named `wk-grep`; no such skill or `skills/grep/`
dir exists, so it was treated as the reporter's guess. Routed by subject grep to the skill
already owning the silent-failure / matcher-dialect family — the same routing its sibling
(ERE `\|` literal pipe) took. Extended that fold's existing uncommitted edit and advanced
its single version bump rather than opening a competing one.
