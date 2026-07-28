---
skill: wk-sharpen
date: 2026-07-28
type: correction
severity: high
verified-against-source: n/a
---

Four sharpen runs were in flight at once; runs must be strictly sequential.

**What happened:** Four background agents were each running a sharpen fold
simultaneously. The user stopped all four and corrected the agent: a run was
supposed to finish before the next one started. Overlapping runs contend over the
same learning pool and the same skill files, so two runs can claim the same
learning, and one run's byte-budget measurement is invalidated by another's edits
landing mid-flight.

**Root cause:** The skill defines what a single run does but never states that
runs are mutually exclusive. Nothing gates spawning on the previous run's
completion, so an interval-driven trigger (a schedule or self-paced loop firing
on a fixed cadence) stacks a new run on top of an unfinished one instead of
skipping that tick.

**Suggested fix:** Encode single-run exclusivity in the skill: before starting a
run, confirm no other sharpen run is in flight and abort if one is. State that a
run ends only when its fold is committed or its verdict is recorded, and that a
cadence trigger firing during an active run must skip that tick rather than
stack a second run. Note the concrete hazards a concurrent run causes — duplicate
claims on one learning, and a byte budget voided by another run's concurrent
edits — so the exclusivity rule is not read as mere tidiness.
