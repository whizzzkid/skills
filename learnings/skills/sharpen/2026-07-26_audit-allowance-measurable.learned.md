---
skill: wk-sharpen
date: 2026-07-26
type: gap
severity: medium
verified-against-source: yes
---

The audit-cleanup byte allowance can be **measured to zero** instead of reserved, by running
the Step 5 audit before locking the budget — which resolves a tight-headroom standoff without
widening the reclaim hunt into load-bearing content.

**What happened:** A fold needed ~261 B in a ceiling-bound `SKILL.md` with only 374 B of
headroom. The rules require budgeting the fold plus a ~25%/floor-300 B audit-cleanup allowance,
which made the total 561 B — over headroom — and the ≥1.2x reclaim target unreachable. The
category-1 reclaim pool was already recorded as exhausted by an earlier fold, with a protected
do-not-re-propose list. Read literally, the budget said "reclaim or don't fold", and the only
remaining targets were protected or load-bearing.

Running the Step 5 audit *first* dissolved the standoff: every cleanup item the audit actually
found landed **outside** the ceiling-bound file — a sibling per-learning record's stale clause,
the linked reference's wrong prescription, the README version line, and the new reference file.
None of those are ceiling-bound, so the in-`SKILL.md` cleanup allowance was genuinely 0 B, not
300 B. Net came to exactly the predicted +261 B, confirmed by the staged measure.

**Root cause:** Verified against the size hook by driving `measure()` verbatim on a staged
throwaway index, pre- and post-edit. The allowance exists because Step 5 cleanup bytes are
*discovered after the budget locks* — the ordering is what guarantees the overrun. But that
ordering is a default, not a constraint: the audit can be run before the budget locks, at which
point the allowance stops being an estimate. The rules state the allowance as an unconditional
reserve with no provision for having measured it, so under tight headroom they mandate reserving
bytes for cleanup that provably will not land in the ceiling-bound file, and push the run toward
a reclaim hunt the skill elsewhere forbids.

**Suggested fix:** Make the allowance conditional on when the audit ran. Reserve the ~25%/floor
estimate when the budget locks before the audit; when the audit has already run, count the
*measured* cleanup bytes that fall inside the ceiling-bound file — which is often zero, because
per-learning records, reference files, and README version lines carry no ceiling. State that
cleanup landing outside the ceiling-bound file costs zero against its budget, and that a
measured allowance replaces the estimate rather than adding to it. Note running the audit early
as the preferred move under tight headroom, since it converts an estimate into a measurement
instead of widening the reclaim hunt.
