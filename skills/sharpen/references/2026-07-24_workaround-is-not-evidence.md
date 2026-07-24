---
class: principle
skill: wk-sharpen
date: 2026-07-24
severity: medium
---

- **Rule:** A workaround that resolves the symptom is not evidence for the mechanism it
  was reasoned from. Before folding a claimed *cause* into a skill, confirm that cause
  exists in the owning source; when auditing, delete a documented cause the source
  disproves.
- **Why:** A fold can record a false-positive shape and a "verified" workaround where
  the workaround succeeds by an unrelated mechanism — e.g. it removes the very flag the
  guard keys on, so the command stops being inspected at all. The symptom clears, the
  reporter reads that as confirmation, and a nonexistent cause becomes durable skill
  text that misdirects the next agent and survives later passes as apparently-verified.
- **Where:** The existing "report is a hypothesis" HARD RULE, merged into its
  non-authoritative bullet rather than added as a fifth (the four-bullet section cap).
- **Evidence:** Found in this run — a previously documented false-block shape named a
  mechanism no code path implemented; the hook was read, the shape probed directly, and
  it verifiably did not fire. The stale bullet and its reference-file entry were both
  corrected in the same pass.
- **Not an escalation:** the "report is a hypothesis" rule postdates the defective fold,
  so this is a gap in the rule's coverage, not a re-violation of it.
