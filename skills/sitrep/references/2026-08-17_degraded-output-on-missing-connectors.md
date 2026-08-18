---
class: principle
status: superseded
superseded-by: 2026-08-17_missing-connectors-abort-publication.md
---

# SUPERSEDED — evidence gaps degrade the artifact; they never truncate the run

> **This rule was reversed by user decision the same day it landed.** A missing
> *required* evidence connector now aborts publication and prompts the user. Do
> not re-propose the degrade-and-publish shape below for that case. The parts that
> survived the reversal are listed under *What survived*. Kept as the record of why
> degrade was tried and why it lost, so a later cycle does not rediscover it.

## What this asserted

**Rule** — Once every gathering fallback is exhausted and a domain is still
toolless, write the page anyway with each unavailable source labelled. Never
render partial output as complete.

**Why** — Treating a missing connector as a terminal hard block produced no
current page at all, while synthesizing from the one reachable domain silently
presented a partial day as complete. Both were judged worse than an explicitly
labelled degraded artifact.

## Why it was reversed

- The degrade path was followed on a live run and did exactly what it promised:
  it published a labelled, incomplete page. The user's quality bar rejects that
  outcome — an incomplete sitrep must not be published at all, because a labelled
  gap still cannot reconstruct meetings, drafts, messages, or strategy work.
- "Never truncate the run" was the wrong invariant. Truncating publication is
  cheap and recoverable; publishing a partial day as the day of record is not.
- The rejection note here — *"Do not re-propose a confirmation prompt for this
  branch"* — rested on the *no interactive triage* HARD RULE forbidding prompts.
  The user has since authorized relaxing that rule for exactly this branch, so the
  ground no longer holds and the note is withdrawn. In the event the relaxation
  proved unnecessary: the abort reports in-response rather than calling
  `AskUserQuestion`, so the tool ban stands intact and only the compile-only clause
  moved.

## What survived

Only the publish-anyway behavior was removed. These still bind, now scoped to gaps
*inside an available domain* rather than to a missing required connector:

- Label every unavailable source; preserve `data-done` and carry-over; drop stale
  dated meeting lines; keep the standup hierarchy; emit no unverified outcome claim.
- Withhold accrual artifacts (rollover marker, brag log) until full evidence can be
  reconciled — this is what keeps an evidence-poor day from being treated as closed,
  and it was never dependent on the degrade path.
