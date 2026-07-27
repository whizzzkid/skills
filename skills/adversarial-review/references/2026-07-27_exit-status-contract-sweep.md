---
class: principle
date: 2026-07-27
severity: high
---

# A gate's exit-status contract is part of the diff, and no sweep read it

**Rule** — when a diff adds or edits code whose caller maps exit status to
severity (verifier task, linter, hook wrapper, CI gate, `--check`/`--verify`
mode), read the caller and record the status→severity mapping before judging the
gate body. Then grep the gate for raising lookups on an absent/renamed key
(`.fetch(`, `T.must(`, `unwrap(`, `panic`, `[]!`, `!.`): the raise exits on a
status the wrapper treats as non-blocking, so the drift the gate exists to catch
ships anyway. Sweep 2.88.

**Why** — every existing sweep asked "is this code correct?"; none asked "what
status does failure produce, and how does the caller read that status?". A gate
read in isolation is clean; the fail-open lives in the seam between it and its
wrapper, and only the pairing exposes it. Two companion requirements ride along:

- A raise→report conversion **adds a branch no existing control drives** — the
  regression passes against the raising form too. Mutation-verify: restore the
  raising form, confirm exactly the new control fails, restore.
- Check **over-firing**, not just under-firing (sweep 2.89). A check reading one
  level of a format that documents inheritance from the enclosing level reports
  false drift on an idiomatic edit and blocks a valid commit. In a blocking gate
  that costs more than a miss — it teaches `--no-verify`. Add a *positive*
  control asserting an idiomatic-but-unusual form reports nothing.

**Where** — `skills/adversarial-review/SKILL.md` → Step 2 Mechanical Sweep
Catalog, rows 2.88 (under-firing / status contract) and 2.89 (over-firing /
format semantics).

## Same-pass reclaim

Both rows are inline (MUST-FOLD: a high-severity lesson may not be routed to a
reference alone). Body headroom was 110 B, so eleven narrow, shape-specific rows
(2.11, 2.12, 2.13, 2.16, 2.21, 2.22, 2.23, 2.26, 2.28, 2.33, 2.48) were relocated
to `sweep-catalog-extended.md` under the standing "relocation does not lower
priority" rule, and the pointer's ID list was regenerated from that file rather
than incremented. The recount also corrected a pre-existing README drift: the
sweep total read 92 against a real 94, and is now 96.
