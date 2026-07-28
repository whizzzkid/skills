---
class: principle
---

**Report** — Two opposite failures at once: the review ran more than once per
session, and it failed to run at all when the work under review *was* an
architecture/spec/plan doc.

**Root cause — one shared defect.** The trigger was restated in each caller
instead of owned by this skill, so each copy diverged and none was authoritative.
Callers that held a copy (PR review, self-review) each dispatched their own run;
callers with no copy (the planning path, the doc-authoring path) never fired at
all. A per-caller trigger cannot be both consistent and complete.

**Principle** — A gate's trigger and its dispatch ownership belong to the gate's
own skill, stated once:

- **Trigger binds to the artifact, not the caller's judgement** — enumerate the
  artifact classes and give a mechanical detector, so "is this architectural?" is
  never a per-caller opinion. Authoring counts as much as reviewing; a doc-only
  diff is not an exemption.
- **One dispatch per artifact version, with a named owner** — the first gate at
  which the artifact is complete. Every other caller reads the recorded verdict; a
  missing record at a non-owner means "not yet at its gate", so route it there
  rather than starting a run.
- **Owner differs by path** — for a doc the session authors, the owner is the
  authoring gate (review before the doc is presented for approval), not the PR
  gate, where the design is already built. Deferring the review to the PR is what
  makes an early-design review worthless.

**Landed as** — a Non-Negotiable Contract in `SKILL.md` (mandatory artifact-driven
trigger with detector, one dispatch per artifact version, delta-scoped re-review,
subagents never satisfy the gate). Callers became readers or were given the
missing trigger: planning owns the authoring path as a mandatory plan element,
the doc-authoring quality gate refuses to deliver an arch-bearing doc with no
recorded verdict, the code-review gate hands the arch layer over exactly once, and
PR review / self-review read the record.

**Generalizes to** — any consult-style gate shared by several callers: duplicated
trigger text produces double-firing and no-firing from the same root, and both
disappear when the trigger and the ownership live with the gate.
