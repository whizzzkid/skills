---
skill: wk-gh
date: 2026-07-28
type: gap
severity: medium
verified-against-source: yes
---

A CI-readiness poll over `statusCheckRollup` must handle both entry shapes, or a pending build reads as green.

**What happened:** An until-loop polled `[.statusCheckRollup[]|select(.status!=null)|select(.status!="COMPLETED")]|length == 0` and returned immediately with three SUCCESS check-runs, while the actual build was still `PENDING`. The raw rollup showed why: the build is a `StatusContext`, whose `.status` and `.conclusion` are both null — the `.status!=null` filter dropped exactly the gate that mattered.

**Root cause:** `statusCheckRollup` mixes two `__typename`s. `CheckRun` carries `.name`/`.status`/`.conclusion`; `StatusContext` carries `.context`/`.state` with no `.status`. Any predicate written against only the check-run fields silently excludes every status context, so external providers (a hosted CI service posting commit statuses) never gate the poll.

**Suggested fix:** In the CI-poll recipe, filter on both shapes and report with coalescing fallbacks:

```bash
until [ "$(gh pr view "$N" --json statusCheckRollup \
  --jq '[.statusCheckRollup[]|select((.state=="PENDING") or (.status=="IN_PROGRESS") or (.status=="QUEUED"))]|length')" = "0" ]; do sleep 45; done
gh pr view "$N" --json statusCheckRollup --jq '[.statusCheckRollup[]|{n:(.name//.context), r:(.conclusion//.state)}]'
```

Also note the sibling trap: an entry with an all-null projection (`{name:null,status:null,conclusion:null}`) is a status context viewed through check-run field names — a signal to re-read the raw rollup, not evidence of an empty gate.
