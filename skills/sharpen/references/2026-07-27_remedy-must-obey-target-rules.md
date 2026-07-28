---
class: principle
skill: wk-sharpen
date: 2026-07-27
severity: medium
---

# A suggested remedy must clear the target's installed rules before it is drafted

**Rule** — Before drafting, check the report's prescribed remedy against the HARD RULEs and
tool-selection rules already installed in the target skill. A remedy naming a command,
endpoint, or path the target already constrains is incidental to the lesson — the reporter
wrote it in whatever tooling they happened to use during the incident. The installed rule
wins: re-express the lesson in the sanctioned tooling and keep only the details that survive
the translation.

**Why the existing rules did not cover it** — Step 1's report-is-a-hypothesis rule
interrogates whether the reported *mechanism* is true; a remedy can be mechanically correct
and still un-foldable. Step 1 also rejects a fold that would *relax* a guard — but this is a
contradiction, not a relaxation. Step 5's "resolve contradictions" runs **after** drafting and
is framed as merging overlapping instructions, so by then the conflicting procedure is already
written, and a new procedure contradicting an old HARD RULE reads as two valid options rather
than as a defect. The fold therefore lands in Step 4, before the draft exists.

**Failure mode it prevents** — installing, in one file, a prescribed procedure that an earlier
rule in the same file forbids. The next run obeys whichever it reads first.

**Generalization** — not tooling-specific. Any suggested remedy naming a command, endpoint, or
file location the target skill already constrains gets the same treatment. The tighter the
report's verified mechanism, the more authority its incidental commands borrow.

**Rejected form (do not re-propose)** — folding the report's remedy verbatim when it prescribes
a transport the target skill bans except behind an approval gate. Recording the rejected form
and the rule it violated is already required by the Step 1 rejected-suggestion bullet; this
record is that entry, not a new obligation.

**Classification** — `principle`. Routed to `SKILL.md` (Step 4) plus this record.

**Escalation** — none. No installed rule states this, so the learning is a gap, not a
re-violation. Verified by full read of `SKILL.md`: Step 1 covers mechanism truth and guard
relaxation, Step 4 covers a gate governing the fold's own landing, Step 5 covers post-draft
contradiction merging — none asks whether the remedy is compatible with installed rules.

**Self-governing fold** — Step 4 is both the edit target and the gate governing this fold's own
drafting, so the **stricter post-edit text** was applied to this fold itself: the report's
suggested fix was checked against `wk-sharpen`'s installed rules before drafting. It conflicts
with none of them (it is additive and names no constrained tooling), so it folded as written,
re-expressed in the skill's bullet idiom rather than the report's prose.

**Arithmetic pass** (staged once, measured with the size hook's `measure()` verbatim):

- Addition **+405 B** — one Step 4 bullet (planned at 385 B; the 20 B gap was an unmeasured
  estimate of a trimmed clause, corrected here against the staged measurement).
- Reclaim **−505 B**, two cut-site relocations into one new curated reference
  ([`harness-defect-triage.md`](harness-defect-triage.md)): Step 1 harness-triage rows
  836 → 615 (**−221**); the guard-staging sub-bullet 284 → 0 (**−284**, covered by the same
  pointer).
- Audit cleanup **measured at 0 B** in-body — every cleanup item (the new reference, this
  record, the README `Version:` bump) lands outside the ceiling-bound file.
- Ratio **505/405 = 1.25×**, above the 1.2× planning target.
- Net **−100 B**; body 24557 → **24457** against the 24576 B ceiling, 119 B clear.

**Where** — `SKILL.md` → Step 4, drafting gate.
