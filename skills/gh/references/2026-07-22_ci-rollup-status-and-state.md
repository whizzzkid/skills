---
class: principle
---

- **Rule**: In the CI-green gate, treat a `statusCheckRollup` entry as
  non-terminal when `.status ∈ {QUEUED,IN_PROGRESS,PENDING}` OR `.state ==
  "PENDING"`, and failing when `.conclusion ∈ {FAILURE,TIMED_OUT,CANCELLED}` OR
  `.state ∈ {FAILURE,ERROR}`. Never gate on `.status` alone.
- **Why**: `statusCheckRollup` is a heterogeneous union — CheckRun nodes expose
  `.status`/`.conclusion`; legacy commit Status nodes expose `.state` with
  `.status == null`. A predicate over one field silently ignores the other node
  type, so a `state: "PENDING"` build reads as green prematurely.
- **Where**: wk-gh `## Reading statusCheckRollup` — hoisted 2026-07-28 out of the
  post-watch re-query block into its own section ahead of it, after a re-violation
  showed the rule was unreachable to an agent hand-rolling a poll instead of using
  `--watch`. Escalated one rung, baseline prose → `**Important:**`.
