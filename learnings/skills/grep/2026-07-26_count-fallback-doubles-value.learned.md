---
skill: wk-grep
date: 2026-07-26
type: correction
severity: medium
verified-against-source: yes
---

`grep -c` prints `0` **and** returns rc=1, so a `|| echo 0` fallback appends a second value
instead of substituting a default — the counter yields `0\n0` and the next arithmetic test aborts.

**What happened:** A batch landing check counted subject matches per item with

```bash
n=$(command grep -c -E -e "$pat" "$file" || echo 0)
[ "$n" -eq 0 ] && { echo MISSING; continue; }
```

For every pattern with no match, `grep -c` wrote `0` to stdout *and* exited 1. The `||` branch
then fired and appended its own `0`, so `n` became the two-line string `0\n0`. `[` rejected it
with `integer expression expected`, the guard fell through, and three of sixteen items were
scored as false negatives on a run where the content was in fact present. The failure is quiet
in the worst way: the shape of the bug (`0`, then `0`) looks exactly like the value the fallback
was meant to produce, so the numbers in the report read plausibly.

**Root cause:** The `cmd || echo <default>` idiom silently assumes the command prints *nothing*
on its failure path. That holds for commands whose non-zero exit signals an *error*. It is false
for commands that print a result and use exit status as a **predicate** about that result —
`grep -c` (rc=1 means "count was zero", not "counting failed"), `grep -o | wc -l`, `comm`, and
similar counters. For those, the failure path is a fully successful run that happens to have
found nothing, and the fallback concatenates rather than substitutes.

**Suggested fix:** For any command whose exit status is a predicate rather than an error signal,
capture the output and ignore rc; supply the default only for genuine emptiness.

```bash
n=$(command grep -c -E -e "$pat" "$file"); n=${n:-0}
```

- Never pair `|| echo <default>` with a command that prints its result on the non-zero path.
- Distinguish the two exit-status meanings before writing a fallback: error signal (`||` is safe)
  vs. predicate about the result (`||` corrupts the value).
- Self-test any counter helper against a known-absent and a known-present input before trusting
  its zeros — a doubled value passes an eyeball check that a single wrong number would fail.
