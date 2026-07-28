---
class: principle
---

# `grep -f` has no comment syntax — a pattern file's comments are live patterns

**Rule** — Strip a pattern file's comment and blank lines before handing it to `grep -f`
(`grep -vE '^[[:space:]]*(#|$)'`), exactly as the owning hooks do. A hand-rolled verdict
binds in **neither** direction: reconcile a hit *and* a zero against the owning hook
before acting on it.

**Why** — `grep` treats every line of a `-f` file as a pattern. A bare `#` line therefore
matches any subject containing `#`, and a blank line matches everything. The comment
convention is meaningful only to the file's intended consumer, so a hand-roll that reads
the file directly inherits scaffolding as patterns and reports a hit the real gate never
sees. Under `-q` the matched pattern is suppressed, so nothing distinguishes the artefact
from a genuine hit.

The false-*dirty* is less dangerous than the false-*clean* but costs a diagnostic cycle
and, worse, trains the operator to discount hand-rolled output — which erodes the
false-clean warning too. Naming only one direction left the other unguarded.

**Verified against source** — Reproduced before drafting:

- The repo denylist carries 21 comment lines, two of them a bare `#`, and zero patterns of
  its own beyond five real entries.
- Unstripped: benign text whose only match was a markdown heading returned rc=0.
- Stripped with the owning hook's own expression: rc=1 on the same input.
- Both owning hooks (`scrub-staged.sh`, `check-prohibited.sh`) strip comments and blanks
  before matching — the skill's own prescribed hand-roll did not, a latent defect in the
  gate this skill runs on itself.

**Classification** — `partial`. The linked reference already warned that a plain-prose
comment self-matches, but only when *choosing a canary*, and it framed the governing risk
as exclusively the false-clean. The pattern-file-consumption mechanism and the
direction-neutral verdict rule are the newly distilled parts.

**Escalation** — One notch, `**CRITICAL**` → `**HIGH-PRIORITY**`, on the "run the owning
hook scripts; never reimplement their matcher" rule. Text installed before the report
(dated via `git log -S`), and the run reimplemented a matcher the hooks own, so the
positive-steering exception does not apply. The repeat traces to the rule's *shape* — it
named only the false-clean, which reads as licensing a hand-roll that can merely
over-report — so the framing fix is load-bearing and the notch only records it.

**Self-governing gate** — The edited Step 5 rule governs this fold's own hook run, and the
Step 3 gate bullet governs its own prohibited-subject scan. Post-edit text is stricter in
both cases and was applied: the subject scan ran with comments stripped, and the hook run
reconciled every hand-rolled scan against the owning hook.

**Arithmetic for this fold** — Addition +130 B (Step 3 gate bullet +97, Step 5 hook rule
+33). Audit cleanup inside the ceiling-bound file: **measured 0 B** — every cleanup item
landed in `references/`, which carries no ceiling. Reclaim NET −157 B from two clauses
their linked references state in full: the Step 3 canary elaboration (−62, pointer kept at
the cut site) and the rejection-note grounds enumeration (−95, stated verbatim in
[`byte-budget.md`](byte-budget.md)). Ratio 1.21×, net **−27 B**, body 24471 → 24444
against a 24576 ceiling.

**Rejected relocations (do not re-propose, grounds stated)** — Scored individually under
the cut-site-pointer shape:

- The `place-inline-then-reclaim` clause and the "route a new catalog row straight to
  `references/`" rule: no linked reference states either, so relocating them drops
  coverage. Durable — grounds are absence of coverage elsewhere, not reading order.
- "Per-hook recovery rows are catalog, not gate": stated only in a *per-learning*
  distillation record, which `SKILL.md` never links, so it proves no coverage. Retire this
  veto if the clause ever lands in a linked reference.
- The `command grep` scope parenthetical at the Step 3 gate: it is that rule's **earliest**
  statement in reading order, and deleting it would move the rule later. Durable.

**Where** — `SKILL.md` → Step 3 prohibited-subject gate (strip rule, `-q` dropped) and
Step 5 owning-hook rule (escalated, direction-neutral). Mechanics in
[`staged-path-scan.md`](staged-path-scan.md) and
[`prohibited-subject-gate.md`](prohibited-subject-gate.md).
