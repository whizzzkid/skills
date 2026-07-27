---
class: principle
---

# `|| echo <default>` corrupts a predicate-status counter

**Rule** — never pair `|| echo <default>` with a command that prints its result on the
non-zero path. Classify the exit status first: an **error signal** (`||` is safe) versus a
**predicate about the result** (`||` corrupts the value). For the predicate class, capture
the output and ignore rc, defaulting only on genuine emptiness — `n=$(command grep -c -e
"$pat" "$file"); n=${n:-0}`.

**Why** — the idiom assumes the command emits nothing when it exits non-zero. For a
counter whose rc encodes a *finding*, the non-zero path is a fully successful run that
already printed. `grep -c` writes `0` **and** returns rc=1, so the fallback appends rather
than substitutes and the variable becomes the two-line string `0\n0`.

Reproduced against the source rather than taken from the report. The report's stated
downstream mechanism — "the guard fell through, and items were scored as false negatives"
— conflates two different arms and does not follow from the shape it printed. What the
reproduction actually shows: `[ "$n" -eq 0 ]` exits **2** (`integer expression expected`),
which is neither true nor false, so the misfire direction is set by the *guard's
polarity*, not by the data:

| guard form | rc=2 behaviour | scored as |
| --- | --- | --- |
| `[ … ] && flag` | non-zero → branch skipped | item silently clean |
| `if [ … ]; then … else flag; fi` | `else` taken | present item flagged |
| under `set -e` | aborts | run dies mid-loop |

Both misfire arms are quiet, and the corrupt value (`0`, then `0`) is the exact digit the
fallback existed to supply, so the tally reads plausibly in either direction. `diff` is in
the same predicate-status class — it prints the delta *and* returns 1.

This is the third polarity of the counting-trap family already in the skill: not too low
(`grep -lc` capping at 1, wrapped-prose false zeros), not too high (`printf` re-running
its format string), but **non-numeric**.

**Where** — `SKILL.md` → Rules → final bullet of the counting-trap cluster, immediately
after the `printf` format-reuse rule.
