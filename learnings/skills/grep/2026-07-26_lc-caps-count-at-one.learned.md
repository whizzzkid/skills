---
skill: wk-grep
date: 2026-07-26
type: surprise
severity: medium
verified-against-source: yes
---

`grep -lc` does not error on the conflicting flags — it caps every count at 1 and emits two
output shapes at once.

**What happened:** A positive control meant to prove a scan was live was written as
`grep -rlc <term> <file>` — reaching for `-l` ("list files containing") and `-c` ("count")
in one invocation. The output was `<file>:0`, which reads as a clean count and was briefly
taken at face value. Re-running with `-c` alone was what settled the question.

**Root cause:** `-l` and `-c` are mutually exclusive in intent, but BSD grep rejects
neither. Driven directly over a two-file fixture where one file contains the term **twice**:

```
grep -rc  term dir   ->  b.txt:0   a.txt:2          # true counts
grep -rlc term dir   ->  b.txt:0   a.txt:1   a.txt  # count capped at 1, plus the -l list
```

Two independent defects, both silent at rc=0:

- **The count is wrong, not absent.** `-l` short-circuits the file after its first match, so
  the counter never advances past 1. `a.txt:1` is a plausible-looking number that is simply
  false — any threshold, delta, or "did the control move the count" check built on it is
  reading a truncated value. A capped count is more dangerous than a missing one because
  nothing about its shape signals corruption.
- **The output interleaves both formats** — `file:count` lines *and* bare filename lines in
  one stream. A consumer parsing on `:` silently mis-parses the bare filenames; flag order
  (`-lc` vs `-cl`) changes nothing.

**Suggested fix:**

- Never combine `-l` and `-c`. Pick the one matching the question: `-l` for "which files",
  `-c` for "how many". Where both are wanted, run two invocations.
- When a count is only being used as a **positive control** (proving a matcher is live), note
  that `-c` under `-l` can never exceed 1 — so a control asserting "the count moved above 1"
  is unsatisfiable by construction and will read as a permanent failure.
- Reinforces the existing rule that a control must be proven to have exercised something: a
  control is only a control once its own invocation form is known-good. A control that is
  itself malformed certifies nothing, and its zero is indistinguishable from the real
  finding it was supposed to rule out.
