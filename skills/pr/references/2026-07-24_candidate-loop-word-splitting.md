---
skill: wk-pr
class: principle
---

**Rule** — Iterate the base-detection candidate set with
`while IFS= read -r CAND; do … done <<< "$CANDIDATES"`. When the loop leaves the
sentinel (`$BEST_DIST == 999999`) untouched, suspect the iteration form before
concluding refs are stale or requiring an explicit base.

**Why** — `$CANDIDATES` is a newline-separated capture. `for CAND in $CANDIDATES` relies
on unquoted parameter-expansion word splitting, which does not happen under zsh — the
body runs once with the whole blob as a single candidate, `git merge-base` fails on it,
`continue` fires, and the sentinel survives. That presents as the already-documented
"detection FAILURE" state, masking the real cause and inviting an unnecessary
"require explicit base" escalation. Complements
`2026-07-09_base-detect-sentinel-failure.md`, which governs what to do once the sentinel
result is trusted.

**Note on the reported cause** — the field report attributed the failure to branch names
containing whitespace or glob characters. Reproduction disproved that as the operative
mechanism: plain, whitespace-free names fail identically, because under zsh the split
never occurs at all. Shell mechanics live in wk-workstyle-shell; this file records the
consuming instance.

**Where** — wk-pr Step 1, merge-base distance loop and the sentinel-failure bullet.
