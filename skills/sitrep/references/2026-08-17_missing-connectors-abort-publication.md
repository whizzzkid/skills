---
class: principle
skill: wk-sitrep
date: 2026-08-17
supersedes: 2026-08-17_degraded-output-on-missing-connectors.md
---

# A missing required evidence connector aborts publication

- **Rule:** Required evidence = the company-data domains (messaging, mail,
  calendar/meeting notes, tracker). Source control alone is never sufficient. Any
  one still toolless after the main-context replay → stop before writing: leave the
  live page byte-unchanged, accrue no rollover marker or brag entry, make no commit
  or push, then name every missing connector in the response and await instruction.
  The prompt is in-response, never `AskUserQuestion` — that tool is not in
  `allowed-tools`, so the *no interactive triage* ban needed no relaxation; only the
  compile-only flow admits the abort as a terminal stop.
- **Why:** Publication is the act that makes a day the day of record. Truncating it
  is cheap and recoverable; publishing a partial day is not, and a labelled gap
  still cannot reconstruct meetings, drafts, messages, or strategy work.
- **Where:** Core hard rules — paired with the *no interactive triage* rule, which
  now carries this abort as its one authorized prompt.

## Reversal record

This reverses a rule installed the same day, hours earlier, by the immediately
preceding sharpen cycle. Recorded explicitly so the degrade shape is not
re-proposed by a later cycle reading only the older commit.

- **What the prior fold asserted:** evidence gaps degrade and never truncate the
  run — fallbacks exhausted and domain toolless still writes the page with each
  unavailable source labelled. It also carried a note forbidding re-proposal of a
  confirmation prompt, grounded in the *no interactive triage* HARD RULE.
- **What superseded it:** hard-block-and-prompt, by explicit user decision after
  the degrade path ran live and published an incomplete page. The user accepted the
  resulting relaxation of *no interactive triage*, so the prompt is authorized and
  the prior rejection note is withdrawn.
- **Why the collision was real, not a duplicate report:** both learnings describe
  the same trigger and reach opposite conclusions. The earlier one reasoned from
  "a stopped run produces nothing"; the later one from "an incomplete day of record
  is worse than no update." The second is the user's bar, and it is the one that
  binds.
- **Scope of the removal:** only publish-anyway. Every preservation guarantee the
  prior fold carried — checkbox state, carry-over, stale-meeting pruning, standup
  hierarchy, no-unverified-claims, and withheld accrual artifacts — was verified to
  be independent of the degrade path and re-scoped to gaps inside an available
  domain. Two of those (no-unverified-claims and accrual withholding) existed
  *only* inside the reversed block, so deleting it wholesale would have silently
  dropped them.

## Naming note

The source learning arrived as `2026-08-17_missing-connectors-degraded.md`, whose
slug collides with the already-committed processed marker for the fold it reverses.
The slug was re-derived from this learning's own conclusion rather than suffixing
the legacy basename; the date is unchanged.
