---
class: principle
---

# Anchor an expensive review gate to merge, not to every push

**Rule**

- An expensive session gate belongs on the **irreversible** action. Publishing (push, PR
  create, mark-ready) is reversible → ungated. Merging, and enabling auto-merge, is not → gated.
- Order the gate *after* publishing so CI runs concurrently with it; fold CI comments and
  review findings into one fix pass.
- When a gate moves, the step it moved to must actually acquire the block. Audit the whole
  chain: a gate removed from the push path with nothing added to the merge path is a silent
  relaxation, not a relocation.

**Why**

- Small, incremental commits make a per-push sweep cost more than the change it guards. A
  push-anchored gate gets rationalized away wholesale; a merge-anchored one stays affordable.
- Reviewing before publishing serialises two independent checks that could run in parallel,
  and discards the reviewer/CI comments that only exist once the change is published.
- The trivial-PR fast path enabled auto-merge on a clear verdict; had the verdict simply moved
  later without `--auto` enablement being reclassified as a *merge* decision, that path would
  have merged unreviewed work.

**Where**

- `wk-workflow` Phase 5.5 (gate relocated after Phase 5 publishing; merge-anchored HARD RULE),
  plus the Skill Reference row, checklist item, and the CI-concurrency note in Phase 6.
- `wk-adversarial-review` contract items 1 and 3, and its `description`.
- `wk-pr`: pre-`create` gate removed; mark-ready no longer waits on a verdict or on CI green;
  `--auto` enablement still requires a clear verdict.
- `wk-pr-merge` Step 5.5 — new verdict precondition, the guard the push path gave up.
- `wk-pr-resolve` Rule 11 and the Step 8 gate — push unconditional, merge conditional.

**Also folded (same paths, this pass)**

- Two field reports arrived mid-run corroborating the mechanism from the caller side: a fix
  loop paid one full review per push until the user waived the gate out of fatigue. They
  targeted paths this fold already held uncommitted, so they were extended into it rather than
  left as a competing fold. Result: `wk-adversarial-review` contract item 11 — one batched
  re-review per session scoped to the cleared SHA, visible invocation count, and a user
  waiver or fatigue signal as an immediate, non-re-litigable hard waiver.
- Relocating the gate removes the per-push trigger; the batching cap covers the residue, since
  even a merge-anchored gate can be re-entered once per fix round.

**Rejected**

- Leaving `wk-pr`'s pre-`create` gate in place "as a cheap first pass" — it is the exact
  per-push cost the report objects to, and a second gate re-creates the multi-gate confusion
  that `single-adversarial-review-gate.md` exists to prevent.
- Dropping the CI-green precondition entirely with the review one. Ready no longer waits on
  green, but the test-plan checkboxes must still not overstate, and merge still requires a
  completed green run for current HEAD.
