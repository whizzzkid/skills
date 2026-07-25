---
skill: wk-pr
date: 2026-07-24
type: gap
severity: medium
verified-against-source: yes
---

The documented base-detection snippet iterates candidates with
`for CAND in $CANDIDATES`, which mis-iterates a newline-separated list of branch
names and produces the sentinel detection failure.

**What happened:** On a branch legitimately stacked on an open PR's head, the
merge-base distance loop as written in the skill returned `BEST_DIST=999999` —
the documented "detection FAILURE" state. Re-running the identical body with
`while IFS= read -r CAND; do … done <<< "$CANDIDATES"` resolved all ten candidates
on the first try and correctly picked the parent branch (distance 7) over the
default branch (distance 11).

**Root cause:** `$CANDIDATES` is built by a command substitution producing one
branch name per line. `for CAND in $CANDIDATES` relies on unquoted word splitting
on `$IFS`, so any branch name containing whitespace, or any glob-active character
in a ref name, yields wrong tokens; each bad token fails `git merge-base` and hits
the loop's `continue`, and when every non-default candidate drops out the sentinel
survives untouched. This is a bug in the snippet, not in the algorithm — it
manifests as the already-documented sentinel failure, which masks the real cause
and invites an unnecessary "require explicit `--base`" escalation.

**Suggested fix:** Replace the `for` loop in the Step 1 snippet with a
`while IFS= read -r CAND; do … done <<< "$CANDIDATES"` read loop so each line is
one candidate verbatim, and add a note under the sentinel-failure guidance that a
`999999` result should first be re-checked with the read-loop form before
concluding detection genuinely failed.
