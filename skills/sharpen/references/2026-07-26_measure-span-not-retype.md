---
source: learnings/skills/sharpen/2026-07-26_measure-span-not-retype.md
date: 2026-07-26
class: principle
severity: medium
verified-against-source: yes
---

# Price the pair you apply, not a pair you composed

**Principle** — Both sides of any byte-arithmetic input must be the exact bytes the editing
tool will receive. Slice `old` out of the file; never compose it by hand beside the `new`
it is being netted against.

**Reported mechanism, and how the reproduction sharpened it** — The field report attributed
the 3 B miss to the `old` string being "a plausible reconstruction of the line rather than
its bytes". A reproduction on the live file disproves that as the load-bearing fault:

- Arm A — a line retyped from the transcript rendering came out **byte-identical** to the
  slice (124 B vs 124 B, `cmp` clean). Retyping is not inherently inexact, so
  "retyped ≠ file bytes" cannot be the mechanism on its own.
- Arm B — pricing a **whole line** (−56 B) and then applying an edit that replaced only the
  **middle of that span** (−6 B) diverged by **50 B**.

So the defect is *pair non-identity*: the priced edit and the applied edit were two different
objects. Slicing fixes it only because it forces `old` to be the real span — the binding
property is that the priced pair IS the applied pair. A *sliced* whole line priced against a
mid-span edit misprices identically, which the report's "slice, don't retype" fix would not
have caught. The editing tool cannot catch it either: it never saw the priced string.

**Why it bites** — The rule that creates this situation (measure before drafting, stage
addition + reclaim together, measure once) fires precisely when headroom is near zero. The
incident's 3 B was absorbed by 22 B of headroom; at 0 B clear the same slip is a ceiling
breach surfacing only at the commit hook, after the fold is written and the version bumped.

**Where** — `SKILL.md` Step 7.5, CRITICAL budget-arithmetic bullet rewritten in place to
require the *exact* old/new pair you will apply. Full mechanics, the 50 B reproduction, and
the estimate-vs-measurement reconciliation rule in
[`byte-budget.md`](byte-budget.md) (linked, so it proves coverage).

**Byte arithmetic** — Baseline body 24554 / 24576 (22 B clear); reclaim pool independently
0. Addition priced as a rewrite-in-place: budget bullet 128 → 162 B (**+34**). Reclaim: the
`tighten the *addition*` bullet's trailing rationale sentence relocated to the already-linked
`byte-budget.md`, 124 → 74 B (**−50**). Measured audit-cleanup allowance **0 B** — the Step 5
audit ran first and found no in-file drift (all 12 reference links resolve). **Net −16**;
staged body **24538**. The ≥1.2× planning ratio was unreachable (50/34 = 1.47× on the reclaim
alone, but the pool held exactly one legitimate target); the binding gate — net non-positive
and every ceiling clear — is met.

**Rejected drafts (do not re-propose)** — Four variants carrying the mid-span illustration
inline (+79 to +109 B) were cut: the illustration is failure-mode rationale, which belongs
behind the already-linked pointer at zero ceiling cost, and none could reach net non-positive.
A variant reclaiming `the hook's` from the measure-exactly-once bullet (−11 B) was dropped as
unnecessary once the rationale relocation cleared the budget — it would have removed the only
inline cue that `measure()` is the size hook's function.

**Rejected reclaim targets (do not re-propose)** — The four size ceilings enumerated inline at
Step 7.5 and the `(~25%/floor ~300 B)` allowance figure: both carry prior recorded rejections
and were honored, not re-opened.
