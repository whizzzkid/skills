---
class: principle
---

**Rule** — Measure PR scope by diffing against `origin/<base>` (fetch first), never
the local base ref. When base detection returns its failure sentinel, retry the
merge-base directly against `origin/<default>` before requiring an explicit
`--base`; trust a succeeding remote result.

**Why** — A local default-branch ref that lags the remote yields an older
merge-base, so `git diff base...HEAD` counts already-merged files as phantom
additions and massively inflates LOC (observed ~990 phantom vs ~490 true). The
same staleness makes the detection loop return its sentinel while a direct
`origin/<base>` merge-base succeeds.

**Where** — wk-pr Step 1: scope-diff block now fetches + diffs `origin/$BEST_BASE`;
the `$BEST_DIST == 999999` sentinel bullet retries against `origin/$DEFAULT_BRANCH`.
