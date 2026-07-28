---
class: principle
date: 2026-07-27
severity: high
---

# A skip-guard that never fires deletes coverage while the suite reports green

**Rule** — Sweep 2.90. When a diff adds, or the reviewed code relies on, a conditional
skip/exclude guard (`skip … unless <pred>`, tag filter, `skipif`, build-matrix exclude):

- Resolve the predicate's operand against the value the **runtime** supplies, not the
  value its name implies.
- Confirm the guard fires in ≥1 configuration and does *not* fire in ≥1 other. Constant
  in either direction is dead.
- Blocker whenever the dead direction is "always skip" — that is silent coverage
  deletion, not a style issue. Fix the operand or delete the guard, then re-run and
  assert the example count rises.

**Why** — The catalog covered tests that assert nothing and tests that are tautological,
but not tests that never execute. 2.3 traces reachability of *guards added by the diff*,
so a pre-existing skip predicate carried unchanged was never evaluated against the value
the runtime actually supplies. Nothing fails: the suite counts the examples as pending,
and the pending count is never read. The examples the tag was added to protect are
exactly the ones it disables — the guard inverts its own purpose.

2.90 states the "carried unchanged by the diff" scope explicitly and cross-references 2.3,
because that scope is the whole reason a separate row exists. Appending the clause to 2.3
was rejected: 2.3 is already the catalog's second-largest row, and a MUST-FOLD lesson
buried mid-row is folded in name only.

## Same-pass reclaim

Body headroom was 858 B against 1631 B of additions across three learnings, so the
headroom trigger fired and net-non-positive was owed. Six narrow, non-MUST-FOLD rows
(2.9.1, 2.17, 2.27, 2.29, 2.35, 2.43) were relocated to `sweep-catalog-extended.md` under
the standing "relocation does not lower priority" rule, and the duplicated runtime-matrix
restatement was cut against its **linked** reference (131 B). Rows 2.88/2.89 were left
inline: the note in `2026-07-27_exit-status-contract-sweep.md` vetoes moving them on
MUST-FOLD grounds, and those grounds still hold. Reclaim 2021 B vs. 1631 B addition =
1.24×, net **−390 B** (23718 → 23328). The pointer's ID list was regenerated from the
extended file, not incremented; the sweep total was recounted from source (96 → 97).

**Where** — `SKILL.md` → Step 2 Mechanical Sweep Catalog, row 2.90.
