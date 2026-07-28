---
class: principle
---

# Coverage proof spans `SKILL.md` plus every reference it links

**Rule** — an `already-covered` verdict is read against the skill **body plus every
reference `SKILL.md` links**, not the body alone. Each citation names the file it came
from. A citation resolving only to an *unlinked* per-learning distillation record proves
nothing at runtime → classify `partial`, not covered.

**Why** — the two gates pull against each other by construction:

- The de-bloat pass *deliberately relocates* full rule statements out of `SKILL.md` into
  linked references, leaving a compressed inline clause plus a pointer. The more a skill
  is de-bloated, the more of its coverage sits behind pointers.
- The coverage gate previously said "the full file" — singular, reading as the body — so
  it never followed the pointers the de-bloat pass created. Topic-level matches then pass
  as rule-level ones because the deciding rule is out of view.
- The converse direction was already handled and is reused rather than restated: only a
  *linked* reference proves coverage, since a per-learning record is never linked from
  `SKILL.md` and so is absent at runtime.

**Observed** — establishing one `already-covered` verdict at rule level took four
citations; only two lived in `SKILL.md`. The other two — including the exact rule the
report's proposed fix named — lived solely in a curated reference `SKILL.md` links. The
gap did not bite that run (a body bullet happened to carry the deciding rule), so the
body-only read reached the right verdict for weaker reasons.

**Where** — `wk-sharpen` Step 3 → `HARD RULE: full-read before already-covered`.

## Reclaim pool note — scored 2026-07-28, under two edit shapes

Scored individually, for this fold's shapes only (in-place clause cut; relocation behind
an existing linked pointer). Re-test under any wider shape.

- **Rejected, permanent** — the batch-mode two-stage-disagreement control bullet: its
  token-selection rule (`sorts identical → wrong token; sorts differ but arms agree →
  mis-sited`) is absent from the linked reference, and it enumerates a control's pass/fail
  checks. Gate checks never move behind a pointer.
- **Rejected, permanent** — the Step 5 hand-rolled-scan verdict protocol and the Step 3
  denylist-direction clause: both are gate verdict rules, restated inline by design.
- **Rejected, shape-contingent** — the Step 1 harness rationale clauses: the linked triage
  reference marks them `(restated inline)`, so the duplication is deliberate.
- **Accepted** — a clause restating its own bullet's imperative, and a parenthetical whose
  distinction this fold now states earlier in reading order.
