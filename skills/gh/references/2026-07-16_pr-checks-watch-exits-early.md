---
class: principle
---

**Rule:** `gh pr checks --watch` can return when a subset of checks resolves
while others are still `PENDING`/`IN_PROGRESS` — its exit is not a terminal-state
guarantee. After the watch exits, re-query the full `statusCheckRollup` and
confirm every check is terminal (`SUCCESS`/`FAILURE`, none pending) before
treating CI as green; re-issue the watch if any check is still pending.

**Why:** A single watch exiting on partial resolution can be mistaken for "CI
complete," marking a PR ready on an incomplete rollup.

**Where:** wk-gh — new "`gh pr checks --watch` is not proof of green" section;
wk-workflow Phase 6 `--watch` bullet cross-refs it. wk-pr Step 5 already
re-polls the rollup to COMPLETED/green (the authoritative ready gate).
