---
class: principle
---

**Rule:** Before trusting `statusCheckRollup`, assert its `headRefOid` equals the
pushed tip (`git ls-remote origin <branch>`); on mismatch the rollup is reporting
a superseded commit — re-query until it catches up, or fall back to the CI
provider's build-by-branch query (ground truth for the current commit).

**Why:** Webhook propagation lags a push, so the rollup's own head-ref OID can
trail the remote tip. A single read (or a `--watch` exit) then reports the prior
commit's state — a staleness axis distinct from the subset-of-checks partial
resolve the skill already warns about.

**Where:** wk-gh, "`gh pr checks --watch` is not proof of green".
