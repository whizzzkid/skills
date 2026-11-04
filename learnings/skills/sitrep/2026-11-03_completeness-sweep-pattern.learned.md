---
skill: wk-sitrep
date: 2026-11-03
type: pattern
severity: medium
verified-against-source: n/a
---

A sweep → master inventory → rewrite → critics pipeline found dozens of missed wins in a review-cycle draft.

**What happened:** Parallel readers (one per reference group) inventoried every win with a coverage tag against the
draft; a merge step deduped into a master inventory file; a rewrite folded in gaps; completeness and voice critics
caught overstated status (open PRs claimed shipped) and duplicated items. The manager 1:1 transcript (meeting-notes
fetch with transcript enabled) supplied the promotion-bar guidance the draft was missing.

**Root cause:** Single-pass drafting from summaries drops small wins, recognition quotes and cross-team influence.

**Suggested fix:** For review-cycle writing, persist a master inventory with coverage tags as a reference artifact,
always include the manager's latest guidance, and remind the user that private-conversation unblocks must be added by
hand.
