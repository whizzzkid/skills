---
class: principle
---

# Split log counts by env and version before any causal claim

**Rule**

- Before comparing counts of two log lines (or one line across time), re-run the same `pup logs aggregate` with
  `--group-by=env,version`, raising `--limit` (a per-facet cap, default 10) to cover every value.
- A line that exists only in some envs or versions → say so and compare only within a shared cell; never infer flow,
  latency, or loss from a cross-deployment ratio.
- Re-derive a causal finding from the grouped query and have an independent check try to refute it before posting it
  to an external tracker.

**Why**

- Ungrouped counts of an "enqueued" and a "published" line matched per minute and supported "received late, not held".
  Grouped, the first series came from a staging env mirroring production traffic, the second from production, and the
  versions deployed that day each emitted only one of the two lines. The conclusion reversed: production accepted on
  time and published late.
- Verified: `pup logs aggregate --group-by=env,version` returns one bucket per `env` x `version` pair, with `--limit`
  applied per facet.
- Considered and rejected: folding into the metrics name-resolution rule. That rule covers an empty series caused by a
  wrong name; this one covers a non-empty series confounded by deployment dimensions, so it gets its own rule.

**Where**

`skills/datadog/SKILL.md` → Logs → HARD RULE: split log counts by `env` and `version`.
