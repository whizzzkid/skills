---
class: principle
skill: wk-sitrep
date: 2026-10-19
supersedes: 2026-08-17_missing-connectors-abort-publication.md
---

# Publish first, report connector gaps after

**Rule**

- A missing, unauthenticated, permission-denied, or blocked connector never stops the run. Write, verify, and commit the
  page from the domains that answered; label every gap in Meta and in the affected section.
- End the final response with a `Connector gaps` report: failure kind, affected sections, fix CTA, plus the
  migrate/waive options. Optional connectors appear only as `(optional)`; waived connectors drop out.
- Brag-log entries still need evidence from an available domain; `end_completed_at:` is written regardless, so a gap
  never re-triggers rollover.

**Why**

- Explicit user direction: a sitrep must always exist for the day, and connector problems are surfaced after it is
  created rather than blocking it. The abort shape produced no page whenever one connector lost auth.

**Reversal record**

- Reverses the 2026-08-17 abort-publication rule (itself a reversal of the degrade shape). Both reversals are user
  decisions; the latest binds. Do not re-propose the abort without a new user instruction.
- Kept from the abort era: waivers (now suppress the report line), roster migration (now offered in the report),
  no-unverified-claims, `data-done`/carry-over preservation.
- Dropped: withholding the rollover marker on a gap (it re-ran `end` every day for a permanently missing connector).

**Also in this change**

- Meeting-notes connector migrated in the roster (user-confirmed), and the metrics connector made optional: its
  sections are omitted when unavailable.
