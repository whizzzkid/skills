---
skill: wk-workstyle-shell
date: 2026-07-27
type: gap
severity: high
verified-against-source: yes
---

`awk`'s `ENVIRON[]` and `-v` / `var=val` assignments are disjoint namespaces, so reading a
`-v`-passed value through `ENVIRON[]` yields an empty string with no diagnostic.

**What happened:** A verification harness passed a cut length to `awk` as a command-line
operand — `awk '…' CUTLEN="$CUT" file` — while the program read it back as
`ENVIRON["CUTLEN"]`. The operand is invisible to `ENVIRON[]`, so the lookup expanded to the
empty string. `substr($0, start, "")` then produced a **zero-length** needle, and
`grep -qF -e ""` matches every input, so all 18 items under test reported OK. The verdict was
clean and unanimous, and nothing in the output marked it as broken. Only the mutated-needle
control caught it: it returned rc=0 where rc=1 was required. The harness's own length guard
did not fire, because it classified len=0 as merely a *short* cut rather than a defect.

**Root cause:** `ENVIRON[]` reflects only the **process environment**. Both `-v name=val` and
a command-line `name=val` operand assign an ordinary `awk` variable in a separate namespace
that never reaches `ENVIRON[]`. Driving `awk` directly confirmed all three arms: the operand
form and the `-v` form both leave `ENVIRON["X"]` empty (a `-v` value is readable only as the
bare variable `X`), while `X=5 awk …` exports it and `ENVIRON["X"]` resolves. Valid program,
empty stderr, rc=0 in every case. The failure polarity is the inverse of the skill's existing
`awk` traps: those manufacture a silent *zero*, this one manufactures a unanimous *pass* that
was never actually tested, which reads as corroboration rather than corruption.

**Suggested fix:** State in the shell skill that `ENVIRON[]` and `-v` / `var=val` are disjoint
— `export` anything intended to be read through `ENVIRON[]`, or read a `-v` variable by its
bare name. Note the propagation path (empty value → zero-length needle → fixed-string match
against everything) and the inverse polarity relative to the two existing `awk` traps, so the
positive-control rule is understood to cover unanimous passes and not only unanimous zeros.
