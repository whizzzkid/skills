---
class: principle
---

# A control for a staged-diff-triggered gate is dead unless the diff is real

**Rule** — Two changes, both landed:

- The control-liveness rule was **generalized out of the Batch Mode preamble** into a new
  top-level *Cross-Cutting Rules* section, framed so each rule binds **its operation, not
  the step hosting it**. It now names source scans, drift probes, and **a gate this fold
  itself just wrote** — the site that was previously uncovered.
- The inline rule requires asserting the **trigger's own input count is non-zero** before
  reading any gate's verdict, because an exit code cannot separate "evaluated and clean"
  from "never ran".
- Mechanics relocated to the already-linked [`harness-defect-triage.md`](harness-defect-triage.md):
  the guard-clause shape, the semantically-null-difference construction (append one trailing
  newline per blob, in a throwaway index), and the "a control family is not verified by its
  members agreeing" sibling instance.

**Why** — The rule existed and covered the case in principle, but it was written about
source scans and traversal primitives inside Batch Mode, so nothing carried it to a Step 5 /
Step 8 control verifying a gate the fold had just added. The specific mechanism was also
unnamed: for a filesystem scan the blind spot is a skipped node class, but for a staged-set
gate it is that **staging is not the trigger — a staged difference is**. Constructing the
control the obvious way (stage the inputs) is exactly what disarms it, so the natural
construction is the broken one, and the dead run is byte-identical to a real pass.

**Verified against the source** — the owning hook's guard was read and driven directly:

- Arm 1 (the reported dead control): stage every `SKILL.md` unmodified → trigger count **0**,
  hook **rc 0**. Reproduced exactly, including the indistinguishable green.
- Arm 2 (rebuilt live): append one trailing newline per blob → trigger count **63**,
  hook rc 0 — a *meaningful* zero over the full population.
- Both arms ran in a throwaway index copy; the real index was confirmed untouched.

**Self-governing fold** — the generalized (post-edit) text is the stricter of the two and
was applied to this run's own controls: every canary and control built this pass asserted
its own liveness before its verdict was read.

**Escalation** — none. The rule never governed the Step 5 / Step 8 control sites, so this is
a genuine coverage gap at those sites, not a re-violation of installed text.

**Byte budget** — addition **+597 B** (Cross-Cutting section); reclaim **−574 B** —
Step 2 empty-listing bullet (−284) and zero-match bullet (−114), both stated in full by the
*linked* [`skill-dir-resolution.md`](skill-dir-resolution.md); the Step 3 `command`-prefix
parenthetical (−67), the Step 5 one-quoted-path restatement (−47), and the Batch-mode
general control claim (−62), all now hoisted. Net **+23 B**; body 24381 → **24404** of
24576, clearing by 172 B. Audit cleanup **measured at 0 B** — every cleanup item (this
record, the sibling record, the reference update, the README `Version:` bump) lands outside
the ceiling-bound file.

**Ratio** — 574/597 = **0.96×**, below the 1.2× planning target and reported rather than
met. The hunt was entered and the addition tightened twice (1004 → 610 → 597 B) rather than
widened into protected content; the binding gate (the ceiling) clears.

**Rejected reclaim target (do not re-propose)** — relocating the Batch-mode
two-stage-disagreement collation-control sub-bullet (481 B). Its recorded veto states
*reachability* grounds, which the skill classifies as a shape-contingent ground now
reopenable via cut-site pointers — but the block is a **control-construction verification
checklist**, and the ceiling rule protects those under every edit shape. The veto therefore
holds on the independent, permanent ground rather than the stale one.

**Where** — `SKILL.md` → *Cross-Cutting Rules* (control liveness), with mechanics in
[`harness-defect-triage.md`](harness-defect-triage.md).
