---
class: principle
---

# Non-unanimity never exonerates a shape-partial gate

**Rule** — A hand-rolled parse gate must accept **every** shape the field occurs in, and
the accepted-shape list comes from the store, not from the documented template. Build one
positive control **per shape**, and reconcile the reject list against the naming convention
before calling a source drained. A non-unanimous verdict is not evidence the gate is sound.

**Why** — The existing guard is keyed on *unanimity* ("a unanimous verdict at any Source 3
stage indicts the tooling"). A shape-partial matcher defeats it by construction: it
correctly classifies the shape it knows and silently drops the shape it does not, so it
*always* produces a split verdict. The guard's sensitivity is therefore inversely
proportional to the severity of the blind spot — the more valid shapes the field has, the
further the verdict sits from unanimous and the less the guard can see. Passing positive
controls do not compensate, because a control synthesized by the matcher's own author
carries the same shape assumption the matcher does; control and matcher share the defect
and agree.

**Verified against the store before drafting** — Not taken from the report. Drove both a
two-shape gate and the reported indented-only gate (`^[[:space:]]+type:`) across the real
memory directory, with a control per shape plus a known non-memory:

- 9 files: 4 carry a flat column-0 `type:`, 3 nest it under `metadata:`, 2 are genuine
  non-memories (a hand-maintained index, an append-only archive) correctly rejected by both.
- Two-shape gate → 7 accept / 2 reject. Indented-only gate → 3 accept / 6 reject,
  reproducing the report's numbers exactly, with all 4 flat-form memories among the rejects.
- Per-shape controls behaved as the principle predicts: the flat control is *accepted* by
  the two-shape gate and *rejected* by the indented-only one. A single nested-only control
  passes against both and would have cleared the broken gate.

**Sharpened against the report** — The report proposed "the memory template's own permitted
shapes are the authority" for the accepted-shape list. The store disproves that: the
documented template prescribes the nested form, yet 4 flat-form memories exist in the
directory. Treating the template as authority therefore reproduces the exact bug. The store
is the authority; the reject-reconcile step is what discovers a shape the template omits.

**Escalation** — One notch, recorded. The two-shape requirement already existed as baseline
prose in two `references/` files, and a run still shipped an indented-only matcher, so the
rule failed and the positive-steering exception does not apply (the learning concedes no
correct firing). Bumped from reference-only prose to an inline `SKILL.md` rule under
Source 3, where the gate is actually built. The reference keeps the procedure.

**Companion note rewritten** — `2026-07-24_memory-scan-parse-gate.md` closed with "the gate
must accept the nested form", phrasing that privileges one shape and plausibly produced this
re-violation. Amended to state the requirement symmetrically, per the rule that a stale
`Rejected` note gets wrongly obeyed or wrongly ignored.

**Arithmetic for this fold** — Addition +213 B (Source 3 unanimity bullet rewritten).
Reclaim −112 B across two later duplicates each stated in full by a *linked* reference:
the blanket-`git add -A` bullet (`commit-gate.md` § "Stage only the paths this run touched",
−64 B) and the Step 5 canary cross-reference (`staged-path-scan.md`, −48 B). Net **+101 B**,
body 23975 → 24076 against the 24576 B ceiling, 500 B clear. Predicted net matched the
staged measure exactly.

**Net positive, deliberately** — The up-front reclaim regime triggered (headroom 601 B under
2× the fold-plus-allowance), but the binding gate's net-non-positive half was unreachable
without cutting load-bearing content: the body is already de-bloated, and every remaining
large bullet either has no *linked* reference backing it (a per-learning distillation record
never proves coverage) or carries a recorded stay-inline decision — the inline phased-approval
restatement, the three inline style rules, the throwaway-index fence, the "zero coverage risk"
rationale, and the deliberate forward cross-reference to the earliest-statement rule. Per the
rule "report the arithmetic, never widen the hunt into load-bearing content", the hunt stopped
at two proven targets. Every ceiling stays clear.

**Rejected reclaim targets (do not re-propose)** — The Source 3 marker-suppression clause
("never add a marker entry for a file this run did not process") is stated in full by the
linked `memory-marker-diff.md` and scored as target #1, but was **kept**: deleting it would
weaken Source 3 at exactly the point this fold strengthens it, and this run relied on it to
confirm the two non-memories were excluded by the gate rather than silenced by a marker
entry. The zero-match-grep bullet in Step 2 is likewise duplicated by the linked
`skill-dir-resolution.md`, but the preceding bullet cross-references it as "the zero-match
rule below" — deleting it would dangle that reference.

**Where** — `SKILL.md` → Batch Mode → Source 3 (global memory files); procedure in
`references/memory-marker-diff.md`.
