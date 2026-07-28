---
class: principle
---

# Adversarial review is one session gate, not a per-phase step

**Rule**

- Declare a session-level idempotent gate (e.g. `wk-adversarial-review`) at exactly one
  owning phase. Do not also list it as a separate run at later phases or "before every push."
- **Anchor an expensive gate to the irreversible action, not to every outbound one.** Publishing
  (push, PR create, mark-ready) is reversible and cheap to redo → it needs no prior verdict.
  Merging is irreversible → it does. Gate merge and auto-merge *enablement*, never the push.
- Order the gate after publishing so CI runs concurrently with it and both sets of findings
  fold into one fix pass. Whichever step is gated must actually block: when the review moves
  after mark-ready, the merge path has to acquire the verdict check the push path gave up.
- Express the "guard every push / PR transition" guarantee by pointing at the gate's
  idempotency contract — re-fire only on new commits since the last clear verdict, sweeping
  only the delta — never by instructing a fresh full re-run per step.

**Why**

- Committing in small chunks makes a per-push sweep cost more than the change it guards, so a
  push-anchored gate gets rationalized away wholesale. A merge-anchored one stays affordable.
- A gate that is documented at "every phase" / "before every push" reads as three independent
  full reviews per session. Agents then re-run the whole sweep redundantly, or perceive a
  contradiction with the "run once per feature" rule.
- The review skill already guarantees single-run-per-change behavior (idempotent within a
  session; scoped re-reviews against `git diff <cleared-sha>..HEAD`). The workflow just has to
  reference that contract once, not restate the invocation per phase.

**Where**

- `skills/workflow/SKILL.md` Phase 5.5 (single-gate declaration, merge anchor, idempotency
  bullets) and the Skill Reference row (collapsed to that phase only).
- The merge anchor is enforced in `wk-pr` (publish/mark-ready ungated; `--auto` enablement
  gated) and `wk-pr-merge` (verdict precondition alongside CI and approvals).
