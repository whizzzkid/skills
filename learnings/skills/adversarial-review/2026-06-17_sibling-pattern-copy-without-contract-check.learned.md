---
skill: wk-adversarial-review
date: 2026-06-17
type: gap
severity: high
---

A `soft_fail` directive was copied from a sibling CI template without verifying that the exit-code contract applied to the new step.

**What happened:** A new publish step was authored by copying a sibling validation template. The sibling used `soft_fail [{ exit_status: 1 }]` because its contract intentionally produces exit codes 0/1/75 for different outcomes. The publish step has no such contract — any failure is team-actionable and should hard-fail. The `soft_fail` was caught by adversarial review as a blocker.

**Root cause:** Sweep 2.2 (sibling-template consistency) checks that analogous fixes are applied to siblings, but it does not prompt the reviewer to verify that the *semantic contract* of a sibling-sourced directive (exit code meaning, soft-fail scope, retry policy) actually applies to the destination step. Pattern copy without contract validation is a distinct failure mode from missing a sibling fix.

**Suggested fix:** Add to Sweep 2.2: when a directive (`soft_fail`, `retry`, `timeout`) is sourced from a sibling template, explicitly verify that the sibling's exit-code or behavioral contract transfers to the new step. If the sibling's contract is documented (e.g. in a spec or comment), quote it; if not, flag the copy as a `blocker` pending verification.
