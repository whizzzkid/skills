---
class: principle
---

# Review depth is a user-chosen mode, not a fixed pipeline

**Rule**

- `light` → diff, description, and PR claims; static review; consume clearance records, never dispatch
  `wk-adversarial-review`. Logic-bearing findings still need one targeted run, else they post as `question:`.
- `medium` (default) → the full pipeline; the harness attacks each changed behavior on several axes; arch and
  functional review run in full.
- `heavy` → confirm first; run the change (Playwright for UI), every local gate, and a happy/sad/edge/mutation matrix.
  Local only.
- Non-interactive callers can never confirm, so they get `medium`.

**Why**

- One fixed depth was either too slow for a quick read or too shallow for a risky change. Making `light` cheap by
  dropping the dispatch keeps it to minutes; making it safe means unproven logic findings downgrade to questions
  instead of turning into unverified concerns.
- `heavy` launches processes and may install dependencies, so it needs explicit consent.

**Where** — `SKILL.md` → Review Modes; Phase 1 Claims bullet; Phase 3 scope line. Caller default:
`sitrep/references/auto-review.md`.
