---
skill: wk-gh
date: 2026-07-22
type: gap
severity: high
---

`statusCheckRollup` entries carry pending state in TWO different fields — a green check must inspect both.

**What happened:** A CI-green poll predicate read only `.statusCheckRollup[].status`, which is populated for CheckRun-type entries but `null` for commit Status-type entries (those use `.state`). A pending build registered as a commit Status (`state: "PENDING"`) and an `IN_PROGRESS` CheckRun were both treated as settled, so the poll reported CI green prematurely.

**Root cause:** GitHub's `statusCheckRollup` is a heterogeneous union: CheckRun nodes expose `.status`/`.conclusion`; legacy commit Status nodes expose `.state` (no `.status`). A predicate over one field silently ignores the other node type.

**Suggested fix:** In the CI-green gate, treat an entry as non-terminal when `.status ∈ {QUEUED,IN_PROGRESS,PENDING}` OR `.state == "PENDING"`, and failing when `.conclusion ∈ {FAILURE,TIMED_OUT,CANCELLED}` OR `.state ∈ {FAILURE,ERROR}`. Never gate on `.status` alone.
